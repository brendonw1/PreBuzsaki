%Moves the baseline

Threshold(CellNum) = get(sblev,'Value');
set(ThresCurve,'ydata',BaseLine+Threshold(CellNum));