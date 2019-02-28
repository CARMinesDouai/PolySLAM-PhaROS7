Class {
	#name : #PSLineFitterTestRun,
	#superclass : #Object,
	#instVars : [
		'polygonRaw'
	],
	#category : #'PolySLAM-Papers-ThesisDichtl'
}

{ #category : #running }
PSLineFitterTestRun >> peek [
	| pc polygon simplifier bounds points |
	
	pc := FLMaterializer materializeFromFileNamed: '/opt/shared/developer/data/vector_maps/lineFitterTest/1/keyframe_0013.VMPointCloud2d.fuel'.
	polygonRaw := VMPolygon fromPointCloud: pc tf: (VMTFMatrix angle: Float twoPi * -0.2995 translation: -0.22@0.33) obstacleDist: 0.1.
	bounds := polygonRaw bounds expandBy: 0.5.
"	bounds := VMRectangle point: -2 @ -2 point: 2@2."
	
	simplifier := VMVectorCollectionSimplifier new.
	simplifier scoring a: 1 b: 4 c: 0.001.
	polygon := simplifier inlierThreshold: 0.2 squared; compute: polygonRaw; result.
	
	points := polygonRaw asPointCollection.
	
	(VMPlotter new)
	   backend: #OSSubprocess;
	   range: bounds;
	   setRatio: -1;
	   plotBackground;
		title: 'peek preview';
		plotChild: (VMPlotBackgroundGrid new);
	   plotChild: (VMPlotPolygonCollection model: {polygon});
		"plotChild: ((VMPlotPointCollection model: points) colorBlock: [:i :s | Color
			h: (360 / (s + 1)) * i
			s: 1.0
			v: 0.667 ]);"
		"setTerminal: 'eps size 20.0,32.0 enhanced font ''Arial.ttf,14''' filename: path,filename, '.eps';"
		"setTerminal: 'png size 2000,2000 enhanced font ''Arial.ttf,24''' filename: path,filename, '.png';"
		addInitLine: 'set term qt size 900,900 enhanced';
		plot.

]

{ #category : #'as yet unclassified' }
PSLineFitterTestRun >> plot: polygon bounds: bounds title: titleString filename: filename [
	| path points pointColors |
	pointColors := [:i :s | Color
			h: (360 / (s + 1)) * i
			s: 1.0
			v: 0.667 ].
	path := '/opt/shared/developer/data/plots/lineFitterTest/'.
	points := polygonRaw asPointCollection.
	(VMPlotter new)
	   backend: #OSSubprocess;
	   range: bounds;
	   setRatio: -1;
		title: titleString;
		plotBackground;
		plotChild: (VMPlotBackgroundGrid new);
	   plotChild: (VMPlotPolygonCollection model: {polygon});
		plotChild: ((VMPlotPointCollection model: points) colorBlock: pointColors);
		setTerminal: 'eps size 10.0,16.0 enhanced font ''Arial.ttf,34''' filename: path,filename, '.eps';
		"setTerminal: 'png size 2000,2000 enhanced font ''Arial.ttf,24''' filename: path,filename, '.png';"
		"addInitLine: 'set term qt size 900,900 enhanced';"
		plot.

]

{ #category : #running }
PSLineFitterTestRun >> run [
	| pc pc2 bounds polygon |
	
	pc := FLMaterializer materializeFromFileNamed: '/opt/shared/developer/data/vector_maps/lineFitterTest/1/keyframe_0013.VMPointCloud2d.fuel'.
	polygonRaw := VMPolygon fromPointCloud: pc tf: (VMTFMatrix angle: Float twoPi * -0.2995 translation: -0.22@0.33) obstacleDist: 0.1.
"	bounds := polygonRaw bounds expandBy: 0.5.
	bounds := VMRectangle point: -2 @ -2 point: 2@2.
	
	{0.01.  0.02.  0.03.  0.04} do: [ :threshold |
		polygon := (VMVectorCollectionSimplifierOld compute: polygonRaw inlierThreshold: threshold squared) result.
		self plot: polygon
			bounds: bounds
			title: 'old algorithm; threshold=', threshold printString
			filename: 'lineFitterBenchmarkOld_', threshold printString. ].
"
	
	"pc2 := pc copy.
	pc2 points: (pc2 points withIndexSelect: [:p :i | i \\ 4 = 0 ]).
	polygonRaw := VMPolygon fromPointCloud: pc2 tf: (VMTFMatrix angle: Float twoPi * -0.2995 translation: -0.22@0.33) obstacleDist: 0.1."
	
	"self runThresholdTest: (polygonRaw)."
	self runParamCTest: polygonRaw.
]

{ #category : #'as yet unclassified' }
PSLineFitterTestRun >> runParamATest: originalPolygon [

	| polygon simplifier |
	
	{ 0.2.  0.5.  1.  2.  4.  8 } do: [ :paramA |
		{ "1.  2."  4.  "8." } do: [ :paramB |
			{ "0.01."  0.001.  "0.0001. 0.00001" } do: [ :paramC |
				{"0.005. 0.01.  0.015.  0.02.  0.025. " 0.03. " 0.035.  0.04.  0.08.  0.2"} do: [ :threshold |
					"Transcript show: 'a='; show: paramA printString;
						show: ' b='; show: paramB printString;
						show: ' c='; show: paramC printString; cr."
					simplifier := VMVectorCollectionSimplifier new.
					simplifier scoring a: paramA b: paramB c: paramC.
					polygon := simplifier inlierThreshold: threshold squared; compute: originalPolygon; result.
					Transcript
						show: polygon size printString;
						show: ' vectors (';
						show: simplifier scoring printParameters;
						show: ' it='; show: threshold printString;
						show: ')'; cr. .
					self plot: polygon
						bounds: (VMRectangle point: -2 @ -1.5 point: 0@1.5)
						title: 'new algorithm; threshold=', threshold printString,
							', a=', paramA printString, ', b=', paramB printString, ', c=', paramC printString,
							'\nvector count=', polygon size printString
						filename: 'paramA_run/','lineFitterBenchmarkNew_',
							threshold printString, '_', paramA printString, '_', paramB printString, '_', paramC printString. 
		
					self plot: polygon
						bounds: (VMRectangle point: 2.8 @ -0.8 point: 4.8@2.2)
						title: 'new algorithm; threshold=', threshold printString,
							', a=', paramA printString, ', b=', paramB printString, ', c=', paramC printString,
							'\nvector count=', polygon size printString
						filename: 'paramA_run/','lineFitterBenchmarkNewX_',
							threshold printString, '_', paramA printString, '_', paramB printString, '_', paramC printString. ]. ]. ]. ].
		

]

{ #category : #'as yet unclassified' }
PSLineFitterTestRun >> runParamBTest: originalPolygon [

	| polygon simplifier |
	
	{ "0.2.  0.5."  1.  "2.  5" } do: [ :paramA |
		{ 0.5.  1.  2.  4.  8.  16.} do: [ :paramB |
			{ "0.01."  0.001.  "0.0001. 0.00001" } do: [ :paramC |
				{"0.005. 0.01.  0.015.  0.02.  0.025.  0.03.  0.035. " 0.04. " 0.08.  0.2"} do: [ :threshold |
					"Transcript show: 'a='; show: paramA printString;
						show: ' b='; show: paramB printString;
						show: ' c='; show: paramC printString; cr."
					simplifier := VMVectorCollectionSimplifier new.
					simplifier scoring a: paramA b: paramB c: paramC.
					polygon := simplifier inlierThreshold: threshold squared; compute: originalPolygon; result.
					Transcript
						show: polygon size printString;
						show: ' vectors (';
						show: simplifier scoring printParameters;
						show: ' it='; show: threshold printString;
						show: ')'; cr. .
					self plot: polygon
						bounds: (VMRectangle point: -2 @ -1.5 point: 0@1.5)
						title: 'new algorithm; threshold=', threshold printString,
							', a=', paramA printString, ', b=', paramB printString, ', c=', paramC printString,
							'\nvector count=', polygon size printString
						filename: 'paramB_run/','lineFitterBenchmarkNew_',
							threshold printString, '_', paramA printString, '_', paramB printString, '_', paramC printString. 
		
					self plot: polygon
						bounds: (VMRectangle point: 2.8 @ -0.8 point: 4.8@2.2)
						title: 'new algorithm; threshold=', threshold printString,
							', a=', paramA printString, ', b=', paramB printString, ', c=', paramC printString,
							'\nvector count=', polygon size printString
						filename: 'paramB_run/','lineFitterBenchmarkNewX_',
							threshold printString, '_', paramA printString, '_', paramB printString, '_', paramC printString. ]. ]. ]. ].
		

]

{ #category : #'as yet unclassified' }
PSLineFitterTestRun >> runParamCTest: originalPolygon [

	| polygon simplifier |
	
	{ "0.2.  0.5."  1.  "2.  5" } do: [ :paramA |
		{ "0.5.  1.  2."  4.  "8." } do: [ :paramB |
			{ 1.  0.1. 0.01.  0.001.  0.0001. 0.00001. 0.000001 } do: [ :paramC |
				{"0.005. 0.01.  0.015.  0.02.  0.025. " 0.03. " 0.035.  0.04.  0.08.  0.2"} do: [ :threshold |
					"Transcript show: 'a='; show: paramA printString;
						show: ' b='; show: paramB printString;
						show: ' c='; show: paramC printString; cr."
					simplifier := VMVectorCollectionSimplifier new.
					simplifier scoring a: paramA b: paramB c: paramC.
					polygon := simplifier inlierThreshold: threshold squared; compute: originalPolygon; result.
					Transcript
						show: polygon size printString;
						show: ' vectors (';
						show: simplifier scoring printParameters;
						show: ' it='; show: threshold printString;
						show: ')'; cr. .
					self plot: polygon
						bounds: (VMRectangle point: -2 @ -1.5 point: 0@1.5)
						title: 'new algorithm; threshold=', threshold printString,
							', a=', paramA printString, ', b=', paramB printString, ', c=', paramC printString,
							'\nvector count=', polygon size printString
						filename: 'paramC_run/','lineFitterBenchmarkNew_',
							threshold printString, '_', paramA printString, '_', paramB printString, '_', paramC printString. 
		
					self plot: polygon
						bounds: (VMRectangle point: 2.8 @ -0.8 point: 4.8@2.2)
						title: 'new algorithm; threshold=', threshold printString,
							', a=', paramA printString, ', b=', paramB printString, ', c=', paramC printString,
							'\nvector count=', polygon size printString
						filename: 'paramC_run/','lineFitterBenchmarkNewX_',
							threshold printString, '_', paramA printString, '_', paramB printString, '_', paramC printString. ]. ]. ]. ].
		

]

{ #category : #'as yet unclassified' }
PSLineFitterTestRun >> runThresholdTest: testPolygon [

	| polygon simplifier |
	
	{ "0.2.  "1."  5" } do: [ :paramA |
		{ "1.  2."  4.  "8." } do: [ :paramB |
			{ "0.01."  0.001.  "0.0001. 0.00001" } do: [ :paramC |
				{0.005. 0.01.  0.015.  0.02.  0.025.  0.03.  0.035.  0.04.  0.08.  0.2} do: [ :threshold |
					"Transcript show: 'a='; show: paramA printString;
						show: ' b='; show: paramB printString;
						show: ' c='; show: paramC printString; cr."
					simplifier := VMVectorCollectionSimplifier new.
					simplifier scoring a: paramA b: paramB c: paramC.
					polygon := simplifier inlierThreshold: threshold squared; compute: testPolygon; result.
					Transcript
						show: polygon size printString;
						show: ' vectors (';
						show: simplifier scoring printParameters;
						show: ' it='; show: threshold printString;
						show: ')'; cr. .
					self plot: polygon
						bounds: (VMRectangle point: -2 @ -1.5 point: 0@1.5)
						title: 'new algorithm; threshold=', threshold printString,
							', a=', paramA printString, ', b=', paramB printString, ', c=', paramC printString,
							'\nvector count=', polygon size printString
						filename: 'threshold_run/','lineFitterBenchmarkNew_',
							threshold printString, '_', paramA printString, '_', paramB printString, '_', paramC printString. 
		
					self plot: polygon
						bounds: (VMRectangle point: 2.8 @ -0.8 point: 4.8@2.2)
						title: 'new algorithm; threshold=', threshold printString,
							', a=', paramA printString, ', b=', paramB printString, ', c=', paramC printString,
							'\nvector count=', polygon size printString
						filename: 'threshold_run/','lineFitterBenchmarkNewX_',
							threshold printString, '_', paramA printString, '_', paramB printString, '_', paramC printString. ]. ]. ]. ].
		

]

{ #category : #'as yet unclassified' }
PSLineFitterTestRun >> runWithPolygon: testPolygon [

	| polygon bounds simplifier |
	
	bounds := testPolygon bounds expandBy: 0.5.
	bounds := VMRectangle point: -2 @ -2 point: 2@2.
	
	
	{ "0.2.  "1."  5" } do: [ :paramA |
		{ "1.  2."  4.  "8." } do: [ :paramB |
			{ "0.01."  0.001.  "0.0001. 0.00001" } do: [ :paramC |
				{0.01.  0.02.  0.03.  0.04} do: [ :threshold |
					"Transcript show: 'a='; show: paramA printString;
						show: ' b='; show: paramB printString;
						show: ' c='; show: paramC printString; cr."
					simplifier := VMVectorCollectionSimplifier new.
					simplifier scoring a: paramA b: paramB c: paramC.
					polygon := simplifier inlierThreshold: threshold squared; compute: testPolygon; result.
					Transcript
						show: polygon size printString;
						show: ' vectors (';
						show: simplifier scoring printParameters;
						show: ' it='; show: threshold printString;
						show: ')'; cr. .
					self plot: polygon
						bounds: (VMRectangle point: -2 @ -2 point: 0@2)
						title: 'new algorithm; threshold=', threshold printString,
							', a=', paramA printString, ', b=', paramB printString, ', c=', paramC printString,
							'\nvector count=', polygon size printString
						filename: 'threshold_run/','lineFitterBenchmarkNew_',
							threshold printString, '_', paramA printString, '_', paramB printString, '_', paramC printString. 
		
					self plot: polygon
						bounds: (VMRectangle point: 2.8 @ -1.8 point: 4.8@2.2)
						title: 'new algorithm; threshold=', threshold printString,
							', a=', paramA printString, ', b=', paramB printString, ', c=', paramC printString,
							'\nvector count=', polygon size printString
						filename: 'threshold_run/','lineFitterBenchmarkNewX_',
							threshold printString, '_', paramA printString, '_', paramB printString, '_', paramC printString. ]. ]. ]. ].
		

]
