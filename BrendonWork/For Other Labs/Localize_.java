import ij.*;
import ij.process.*;
import ij.gui.*;
import java.awt.*;
import ij.plugin.filter.*;

public class Localize_ implements PlugInFilter {

	public int wsize = 2;

	public int setup(String arg, ImagePlus imp) {
		return DOES_16;
	}

	public void run(ImageProcessor ip) {
		int w = ip.getWidth();
		int h = ip.getHeight();
		ImagePlus localized = NewImage.createShortImage("Localized image",w,h,1,NewImage.FILL_BLACK);
		ImageProcessor nip = localized.getProcessor();
		short[] pixels = (short[]) ip.getPixels();
		short[] npixels = (short[]) nip.getPixels();
		int offset, woffset;
		int ymin, ymax, xmin, xmax;
		double sum, npix;
		for (int y = 0; y < h; y++) {
			offset = y*w;
			for (int x = 0; x < w; x++) {
				ymin = 0;
				ymax = h-1;
				xmin = 0;
				xmax = w-1;
				if (y > wsize) ymin = y - wsize;
				if (y < h - wsize) ymax = y + wsize;
				if (x > wsize) xmin = x - wsize;
				if (x < w - wsize) xmax = x + wsize;
				npix = (ymax - ymin + 1)*(xmax - xmin + 1);
				sum = 0;
				for (int wy = ymin; wy <= ymax; wy++) {
					woffset = wy*w;
					for (int wx = xmin; wx <= xmax; wx++) {
						sum = sum + pixels[woffset + wx] / npix;
					}
				}
				sum = pixels[offset+x] / sum * 100;
				npixels[offset+x] = (short) sum;
			}
		}
		localized.show();
		localized.updateAndDraw();
	}

}
