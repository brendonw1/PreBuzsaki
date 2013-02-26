import ij.*;
import ij.process.*;
import ij.gui.*;
import ij.io.*;
import java.awt.*;
import java.io.*;
import ij.plugin.*;
import ij.plugin.filter.*;

public class ReadTraces_ implements PlugInFilter {

	protected ImageStack stack;
	
	public int setup(String arg, ImagePlus imp) {
		stack = imp.getStack();
		return DOES_16+SUPPORTS_MASKING;
		}

	public void run(ImageProcessor ip) {
		ImagePlus curr = new ImagePlus("Title",ip);
		OpenDialog od = new OpenDialog("Choose a contour (*.ccf) file", null);
		String name = od.getFileName();
		if (name==null)
			return;
		String dir = od.getDirectory();
		OpenDialog od2 = new OpenDialog("Choose a trace (*.trc) file", null);
		String name2 = od2.getFileName();
		if (name2==null)
			return;
		String dir2 = od2.getDirectory();
		double nc, np;
		int ncells, npts, cn;
		try {
			DataInputStream r = new DataInputStream(new FileInputStream(dir+name));
			DataOutputStream t = new DataOutputStream(new FileOutputStream(dir2+name2));
			nc = r.readDouble();
			ncells = (int) nc;
			IJ.setColumnHeadings("Contour	Number of Points	Rectangle	Perimeter");
			IJ.write("Number of contours: "+ncells);
			t.writeDouble(ncells);
			IJ.write("Number of stacks: "+stack.getSize());
			t.writeDouble((double) stack.getSize());
			for (int c = 1; c <= ncells; c++) {
				np = r.readDouble();
				npts = (int) np;
				double[] cx = new double[npts];
				double[] cy = new double[npts];
				int[] ix = new int[npts];
				int[] iy = new int[npts];
				for (int d = 0; d < npts; d++) {
					cx[d] = r.readDouble();
					ix[d] = (int) cx[d];
					cy[d] = r.readDouble();
					iy[d] = (int) cy[d];
					}
				PolygonRoi pr = new PolygonRoi(ix,iy,npts,curr,Roi.POLYGON);
				curr.setRoi(pr);
				int width = ip.getWidth();
				Rectangle rc = ip.getRoi();
				int offset, i;
				int[] msk = pr.getMask();
				double sum = 0;
				int ar = 0;
				for (int j = 1; j <= stack.getSize(); j++) {
					short[] pixels = (short[]) stack.getPixels(j);
					ar = 0;
					sum = 0;
					for (int y = rc.y; y < (rc.y+rc.height); y++) {
						offset = y*width;
						for (int x = rc.x; x < (rc.x+rc.width); x++) {
							i = offset + x;
							if (msk[(y-rc.y)*rc.width+x-rc.x] <-1) {
								sum += (double) pixels[i];
								pixels[i] = 0;
								ar++;
								}
							}
						}
					for (int d = 0; d < npts; d++) {
						i = iy[d]*width + ix[d];
						if (pixels[i] > 0) {
							sum += (double) pixels[i];
							ar ++;
							}
						}
					sum = sum / ar;
					t.writeDouble(sum);
					}
					IJ.write(c+"	"+ar+"	"+rc.height+"x"+rc.width+"	"+pr.getLength());
			}
			curr.updateAndDraw();
			r.close();
			t.close();
		} catch (IOException e) {
			IJ.error("Error!"); }
	}
}
