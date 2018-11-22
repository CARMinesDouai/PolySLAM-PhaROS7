Class {
	#name : #PSNNFFICollectionTest,
	#superclass : #VMTests,
	#category : #'PolySLAM-Tests'
}

{ #category : #tests }
PSNNFFICollectionTest >> testAdd [
	"testing horizontal vectors"
	| grid data vectors |
	
	grid := PSFFINNCollection new.
	data := {
		{ 1.1 @ 0.5.  3.3 @ 0.5 }.
		{ 2 @ 2.  -2 @ 2 }.
		{ 1.1 @ 0.2.  1.8 @ 0.2 }.
	}.
	
	vectors := data collect: [ :points | VMLineSegment from: points first to: points last ].
	
	vectors do: [ :v | grid add: v ].
	grid cleanup.
	

]

{ #category : #tests }
PSNNFFICollectionTest >> testAdd2 [
	"testing non-horizontal vectors (pointing upwards)"
	| grid data vectors |
	
	grid := PSFFINNCollection new.
	data := {
		{ 1.1 @ 0.25.  3.3 @ 0.75 }.
		{ 2 @ 2.  -2 @ 3 }.
		{ 1.1 @ 0.2.  1.8 @ 0.8 }.
		{ 2.1 @ 0.2.  2.8 @ 3.8 }.
	}.
	
	vectors := data collect: [ :points | VMLineSegment from: points first to: points last ].
	
	vectors do: [ :v | grid add: v ].
	grid cleanup 

]

{ #category : #tests }
PSNNFFICollectionTest >> testAdd3 [
	"testing non-horizontal vectors (pointing downwards)"
	| grid data vectors |
	
	grid := PSFFINNCollection new.
	data := {
		{ 1.1 @ 0.75.  3.3 @ 0.25 }.
		{ 2 @ 2.  -2 @ 0 }.
		{ 1.1 @ 0.8.  1.8 @ 0.2 }.
		{ 2.1 @ 3.8.  2.8 @ 1.2 }.
		{ 0.1 @ 3.8.  -2.8 @ 1.2 }.
	}.
	
	vectors := data collect: [ :points | VMLineSegment from: points first to: points last ].
	
	vectors do: [ :v | grid add: v ].
	grid cleanup 
	

]

{ #category : #tests }
PSNNFFICollectionTest >> testFindNearest [
	| points vector grid searchPoints result expectedResults |
	points := { -1.5 @ -0.5.  3.5 @ 1.1 }.
	vector := VMLineSegment from: points first to: points last.
	grid := PSFFINNCollection new.
	grid add: vector.
	searchPoints := { -2 @ -1.  -2 @ -0.5.  0 @ 0. }.
	expectedResults := {}.
	
	searchPoints do: [ :sp |
		result := grid findNearest: sp.
		self assert: result object equals: (vector closestPoint: sp).
	].
	grid cleanup 
	
]

{ #category : #tests }
PSNNFFICollectionTest >> testFindNearest2 [
	| points vectors grid searchPoints result nearestVector |
	
	points := {
		{ -1.5 @ -0.5.  3.5 @ 1.1 }.
		{ 3.5 @ 1.1.  0 @ 0.9 }.
		{ 0 @ 0.9.  -1.5 @ -0.5 }
	}.
	vectors := points collect: [ :pointCollection | VMLineSegment from: pointCollection first to: pointCollection last ].
	grid := PSFFINNCollection new.
	vectors do: [ :v | grid add: v ].
	searchPoints := { -2 @ -1.  -2 @ -0.5. 0 @ 0.  1.5 @ 1.5.   -1 @ 0. }.
	nearestVector := { 1. 1. 1. 2. 3. }.
	
	searchPoints with: nearestVector do: [ :sp :vecIndex |
		result := grid findNearest: sp.
		self assert: result object equals: ((vectors at: vecIndex) closestPoint: sp).
	].
	grid cleanup
]

{ #category : #tests }
PSNNFFICollectionTest >> testFindNearest3 [
	| vector grid searchPoints result expectedResults |

	vector := VMLineSegment from: 4@0 to: 4@4 type: 1.
	grid := PSFFINNCollection new.
	grid add: vector.
	searchPoints := { 3.5@2 }.
	expectedResults := {4@2}.
	
	searchPoints with: expectedResults do: [ :sp :er |
		result := grid findNearest: sp.
		self assert: (result object dist: er) < 0.00000001.
	].
	grid cleanup
]

{ #category : #tests }
PSNNFFICollectionTest >> testFindNearestSensorPoint [
	| pc pc2 pc3 rand polygon grid icp tf sensorPoint sensorPoint3 pc4|
	
	polygon := VMPolygon fromPoints: { 0@0.  4@0.  4@6.  4.4@6.  4.4@0.  10@0.  10@10.  0@10 } withTypes: { 1.  1.  1.  1.  1.  1.  1.  1. }.
	
	sensorPoint := 2@2.
	
	pc := OrderedCollection new.
	1 to: 4 by: 0.5 do: [ :x | pc add: x@0 ].
	0.5 to: 4 by: 0.5 do: [ :y | pc add: 4@y ].
	
	rand := Random seed: 12345. "setting a fixed seed to get the exact same results for every test run"
	pc2 := pc collect: [ :p | p + (rand next - 0.5 / 10.0) ].
	
	tf := VMTFMatrix angle:0.1 translation: 0.1@0.2.
	pc3 := pc2 collect: [ :p | p transform: tf ].
	sensorPoint3 := sensorPoint transform: tf.
	
	
	
	grid := PSFFINNCollection new.
	grid addAll: polygon.
	
	icp := VMVectorICP new maxIterations: 30; outlierThresholdFalloff: 0.1.
	icp compute: pc3 with: grid sensorPoint: sensorPoint3.
	Transcript show: (icp finalTF * tf) printString; cr.
	pc4 := pc3 collect:[:p | p transform: icp finalTF].
	{ polygon.  pc asVMPointCollection asRenderableElement color: Color cyan.  pc3 asVMPointCollection asRenderableElement color: Color orange. pc4 asVMPointCollection asRenderableElement color: Color green } asRenderableElement inspect.
	self assert: (icp finalTF * tf) angle < 0.002.
	self assert: ((icp finalTF * tf) translate asPoint dist: 0@0) < 0.02.
	"icp inspect."
	grid cleanup 
]
