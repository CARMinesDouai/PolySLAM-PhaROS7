Class {
	#name : #VMScreenshotExamples,
	#superclass : #Object,
	#category : #'PolySLAM-Extra-Examples'
}

{ #category : #'as yet unclassified' }
VMScreenshotExamples class >> exampleLoopClosure [
	| minIndex maxIndex polygons timeSpentOnICP startPolygon cr icp icpTF nnc |

"load maps"
minIndex := 1.
maxIndex := 500.
polygons := (VMMapLoader load: 'gazebo_office/run2/keyframe_' from: minIndex to: maxIndex) polygons.
"polygons := (VMMapLoader load: 'sang/auto_gmapping/keyframe_' from: minIndex to: maxIndex) polygons."
polygons asRenderableElement.
"perform ICP and store results in 'newPC'"
[ timeSpentOnICP := [
	"create starting nnCollection for ICP. removes frontiers for the nnc"
	startPolygon := (VMVectorCollectionSimplifier compute: polygons first) result.
	cr := VMCollectionRenderer new.
	cr collection add: (startPolygon asRenderableElement color: (Color byInteger: minIndex); lineWidth: 0.01).
	icp := (VMVectorICP new) outlierThresholdFalloff: 1; outlierStartThreshold: 0.8; maxIterations: 35; yourself.
	icpTF := VMTFMatrix identity.
	nnc := VMNNVectorGrid new.
	nnc addAll: (startPolygon select: [ :vec | vec isObstacle ]).
	2 to: (polygons size) do: [ :index |
		| p newPolygon result sensorPoint |
		p := (polygons at: index) transform: icpTF.
		sensorPoint := p last pointA.
		icp compute:
				((p asPointCollection) removeLast; yourself)
			with: nnc
			"sensorPoint: sensorPoint".
		
		icpTF := icp finalTF * icpTF.
		result := p transform: icp finalTF.
		"Transcript show: '    finalTF='; show: icp finalTF printString; cr."
		newPolygon := (VMVectorCollectionSimplifier compute: result) result.
		nnc addAll: (newPolygon select: [ :vec | vec isObstacle ] as: VMLinearNNSVectorCollection).
		cr collection add: (newPolygon asRenderableElement color: (Color byInteger: (index+minIndex-1)); lineWidth: 0.01).
	]] timeToRun.
	Transcript show: 'time spend on ICP: '; show: (timeSpentOnICP totalSeconds asFloat round: 2) printString; show:'s'; cr.
	nnc asRenderableElement inspect.
] forkAt: 40.
]

{ #category : #'as yet unclassified' }
VMScreenshotExamples class >> exampleLoopClosure21 [
	| minIndex maxIndex polygons mapLoader timeSpentOnICP startPolygon cr icp icpTF nnc |

"load maps"
minIndex := 1.
maxIndex := 512.
mapLoader := VMMapLoader load: 'gazebo_office/run2.1/keyframe_' from: minIndex to: maxIndex.
polygons := mapLoader polygons.

"perform ICP and store results in 'newPC'"
[ timeSpentOnICP := [
	"loop setup"
	startPolygon := (VMVectorCollectionSimplifier compute: polygons first) result" transform: mapLoader maps first tf inverse".
	cr := VMCollectionRenderer new.
	cr collection add: (startPolygon asRenderableElement color: (Color byInteger: minIndex); lineWidth: 0.01).
	icp := (VMVectorICP new) outlierThresholdFalloff: 1; outlierStartThreshold: 0.8; maxIterations: 35; yourself.
	icpTF := mapLoader maps first tf.
	nnc := VMNNVectorGrid new.
	nnc addAll: (startPolygon select: [ :vec | vec isObstacle ]).
	2 to: (polygons size) do: [ :index |
		| p newPolygon result sensorPoint |
		p := (polygons at: index) transform: icpTF" * ((mapLoader maps at: index) tf inverse)".
		sensorPoint := p last pointA.
		icp compute:
				((p asPointCollection) removeLast; yourself)
			with: nnc
			"sensorPoint: sensorPoint".
		
		icpTF := icp finalTF * icpTF.
		result := p transform: icp finalTF.
		"Transcript show: '    finalTF='; show: icp finalTF printString; cr."
		newPolygon := (VMVectorCollectionSimplifier compute: result) result.
		nnc addAll: (newPolygon select: [ :vec | vec isObstacle ] as: VMLinearNNSVectorCollection).
		cr collection add: (newPolygon asRenderableElement color: (Color byInteger: (index+minIndex-1)); lineWidth: 0.01).
	]] timeToRun.
	Transcript show: 'time spend on ICP: '; show: (timeSpentOnICP totalSeconds asFloat round: 2) printString; show:'s'; cr.
	nnc asRenderableElement inspect.
] forkAt: 40.
]

{ #category : #'as yet unclassified' }
VMScreenshotExamples class >> exampleSectorBorders [
	| polygons polygons2 |
	polygons := {
		VMPolygon fromPoints: { -1@1.  1@1.  3.5@6.  -4@6.  -4@4. } withTypes: { 1. 3. 1. 1. 3. }.
		VMPolygon fromPoints: { 1@1.  1@ -1.  3.5@ -2.  3.5@6 } withTypes: { 1. 3. 1. 3. }.
		VMPolygon fromPoints: { 1@ -1.  -1@ -1.  -5@ -3.5.  3.5@ -3.5.  3.5@ -2 } withTypes: { 1. 3. 1. 1. 3. }.
		VMPolygon fromPoints: { -1@ -1.  -1@1.  -4@4.  -6@4. -6@ -3.5. -5@ -3.5 } withTypes: { 1. 3. 1. 1. 1. 3. }.
	} asVMPolygonCollection.
	
	polygons2 := VMPolygonCollection new.
	polygons2 add: (polygons first transform: (VMTFMatrix angle: 0 translation: 0@0.3)).
	polygons2 add: (polygons second transform: (VMTFMatrix angle: 0 translation: 0.3@0)).
	polygons2 add: (polygons third transform: (VMTFMatrix angle: 0 translation: 0@ -0.3)).
	polygons2 add: (polygons fourth transform: (VMTFMatrix angle: 0 translation: -0.3@0)).
	
	"polygons2 inspect."
	
	(VMViewer openOn: { polygons } extent: 640@640)
		showDebugInfo: false;
		hideGrid;
		backgroundColor: Color veryLightGray;
		zoomFactor: 55.00 at: 380@390;
		"exportAsPNG: '/home/jd/Pictures/pharo/ICRA2019_';"
		yourself.

]
