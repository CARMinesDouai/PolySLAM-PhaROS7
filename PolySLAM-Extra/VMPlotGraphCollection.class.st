Class {
	#name : #VMPlotGraphCollection,
	#superclass : #VMPlotObject,
	#category : #'PolySLAM-Extra-Gnuplot plotter'
}

{ #category : #plotting }
VMPlotGraphCollection >> plotParent: parent [
	| hue deltaHue |
	super plotParent: parent.
	
	hue := 0.0.
	deltaHue := Float twoPi / (model size + 1).
	
	model do: [ :graph |
		parent plotChild: (
			(VMPlotGraph model: graph)
				nodeColor: (Color h: hue s: 1.0 v: 0.85);
				edgeColor: (Color h: hue s: 1.0 v: 1.0)).
		hue := hue + deltaHue.].
]
