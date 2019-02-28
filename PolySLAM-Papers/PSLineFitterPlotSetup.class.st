Class {
	#name : #PSLineFitterPlotSetup,
	#superclass : #Object,
	#instVars : [
		'polygonRaw'
	],
	#category : #'PolySLAM-Papers-ThesisDichtl'
}

{ #category : #plotting }
PSLineFitterPlotSetup >> plot [
	| pc pc2 bounds points colorBlock path |
	
	pc := FLMaterializer materializeFromFileNamed: '/opt/shared/developer/data/vector_maps/lineFitterTest/1/keyframe_0013.VMPointCloud2d.fuel'.
	polygonRaw := VMPolygon fromPointCloud: pc tf: (VMTFMatrix angle: Float twoPi * -0.2995 translation: -0.22@0.33) obstacleDist: 0.1.
	path := '/opt/shared/developer/data/plots/lineFitterTest/'.
	colorBlock := [:i :s | Color
			h: (360 / (s + 1)) * i
			s: 1.0
			v: 0.667 ].
	
	bounds := polygonRaw bounds expandBy: 0.5.
	"bounds := VMRectangle point: -2 @ -2 point: 2@2."
	
	pc2 := pc copy.
	pc2 points: (pc2 points withIndexSelect: [:p :i | i \\ 4 = 0 ]).
	"polygonRaw := VMPolygon fromPointCloud: pc2 tf: (VMTFMatrix angle: Float twoPi * -0.2995 translation: -0.22@0.33) obstacleDist: 0.1."
	
	points := polygonRaw asPointCollection.
	
	(VMPlotter new)
	   backend: #OSSubprocess;
	   range: bounds;
	   setRatio: -1;
	   plotBackground;
		"title: 'LineFitterTest raw polygon';"
		addInitLine: 'set format x ""';
		addInitLine: 'set format y ""';
		plotChild: (VMPlotBackgroundGrid new);
	   plotChild: (VMPlotPolygonCollection model: {polygonRaw});
		plotChild: ((VMPlotPointCollection model: points) colorBlock: colorBlock);
		setTerminal: 'eps size 20.0,22.0 enhanced font ''Arial.ttf,34''' filename: path, 'lineFitterPolygonRaw.eps';
		"setTerminal: 'png size 2000,2000 enhanced font ''Arial.ttf,24''' filename: path, 'lineFitterPolygonRaw.png';"
		"addInitLine: 'set term qt size 900,900 enhanced';"
		plot.

]
