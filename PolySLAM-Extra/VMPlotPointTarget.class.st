Class {
	#name : #VMPlotPointTarget,
	#superclass : #VMPlotObject,
	#category : #'PolySLAM-Extra-Gnuplot plotter'
}

{ #category : #plotting }
VMPlotPointTarget >> plotParent: parent [
	super plotParent: parent.
	
	self plotPointCollection: { model } extra: 'pointtype 6 pointsize 1.33 lc rgb ''#0000ff'' lw 2 notitle'.
	

]
