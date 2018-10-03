Class {
	#name : #VMICPBaseAlgotithm,
	#superclass : #Object,
	#instVars : [
		'nnCollection',
		'collectionHistory',
		'tfHistory',
		'matchHistory',
		'maxIterations',
		'sensorPointHistory',
		'useSensorPoint'
	],
	#category : #'PolySLAM-Core-SLAM - ICP'
}

{ #category : #'as yet unclassified' }
VMICPBaseAlgotithm class >> rendererClass [
	^VMICPRenderer
]

{ #category : #transformation }
VMICPBaseAlgotithm >> applyTransform [
	| tf |
	"applies the latest transformation in tfHistory to the input collection and places the result in collectionHistory.
	the original collection is not modified."
	
	tf := tfHistory last.
	collectionHistory add: (collectionHistory first collect: [ :aPoint |	tf transformPoint: aPoint ]).
	"collectionHistory add: (collectionHistory first transform: tf)."
	
	(sensorPointHistory isNotEmpty and: [sensorPointHistory first isNotNil]) ifTrue: [
		sensorPointHistory add: (sensorPointHistory first transform: tf).
	].
	
]

{ #category : #converting }
VMICPBaseAlgotithm >> asRenderableElement [
	^ self class rendererClass new model: self
]

{ #category : #accessing }
VMICPBaseAlgotithm >> bounds [
	"returns the bounds of the original input (nnCollection and initial point cloud)"
	| rect |
	rect := nil.
	
	nnCollection
		ifNotNil: [rect
			ifNil: [ rect := nnCollection bounds. ]
			ifNotNil: [ rect := rect merge: nnCollection bounds. ]].
	
	collectionHistory
		ifNotNil: [ rect
			ifNil: [ rect := collectionHistory first bounds.]
			ifNotNil: [ rect := rect merge: collectionHistory first bounds. ]
			].
	
	^rect
]

{ #category : #'abort conditions' }
VMICPBaseAlgotithm >> checkAbortCondition [
	"note: tfHistory contains the initialGuess as first entry and one entry for each loop iteration"
	^ tfHistory size - 1 > maxIterations

]

{ #category : #accessing }
VMICPBaseAlgotithm >> collectionHistory [
	^collectionHistory
]

{ #category : #'public: compute' }
VMICPBaseAlgotithm >> compute: aPointCollection with: aNNCollection [
	^ self compute: aPointCollection with: aNNCollection initialGuess: VMTFMatrix identity
]

{ #category : #'public: compute' }
VMICPBaseAlgotithm >> compute: aPointCollection with: aNNCollection initialGuess: aTFMatrix [
	"setup sets up the 'history' collections"
	self setup.
	
	"add the initial entries at the 'history' collections"
	self inputCollection: aPointCollection asVMPointCollection.
	self nnCollection: aNNCollection.
	self initialGuess: aTFMatrix.
	
	"apply the initialGuess transformation"
	self applyTransform.
	
	"run the main loop of the algorithm"
	self loop.
	
	"finalize and return"
	^ self finalize
]

{ #category : #'public: compute' }
VMICPBaseAlgotithm >> compute: aPointCollection with: aNNCollection initialGuess: aTFMatrix sensorPoint: sensorPoint [
	"setup sets up the 'history' collections"
	self setup.
	
	"add the initial entries at the 'history' collections"
	self inputCollection: aPointCollection asVMPointCollection.
	self nnCollection: aNNCollection.
	self initialGuess: aTFMatrix.
	self sensorPoint: sensorPoint.
	
	"apply the initialGuess transformation"
	self applyTransform.
	
	"run the main loop of the algorithm"
	self loop.
	
	"finalize and return"
	^ self finalize
]

{ #category : #'public: compute' }
VMICPBaseAlgotithm >> compute: aPointCollection with: aNNCollection sensorPoint: sensorPoint [
	^ self compute: aPointCollection with: aNNCollection initialGuess: VMTFMatrix identity sensorPoint: sensorPoint
]

{ #category : #transformation }
VMICPBaseAlgotithm >> computeTransformation [
	self subclassResponsibility
]

{ #category : #'pair matching & outlier detection' }
VMICPBaseAlgotithm >> createMatchPairs [
	self subclassResponsibility
]

{ #category : #accessing }
VMICPBaseAlgotithm >> finalCollection [
	"returns the latest pointCollection from the ICP matching"
	^collectionHistory last
]

{ #category : #accessing }
VMICPBaseAlgotithm >> finalError [
	^matchHistory last squaredError.
]

{ #category : #accessing }
VMICPBaseAlgotithm >> finalTF [
	"returns the transformation (VMTFMatrix) of the latest point collection in collectionHistory"
	^tfHistory last
]

{ #category : #'basic algorithm' }
VMICPBaseAlgotithm >> finalize [
	"debug and logging messages go here"
]

{ #category : #'GT Inspector' }
VMICPBaseAlgotithm >> gtInspectorRenderedIn: composite [
	<gtInspectorPresentationOrder: 50>
	"composite inspectOnce."
	(composite morph)
		title: 'Viewer';
		morph: [
			(VMViewer openWindowlessOn: { self asRenderableElement })
				autozoom.
		].
		
]

{ #category : #accessing }
VMICPBaseAlgotithm >> initialGuess: aTFMatrix [
	tfHistory add: aTFMatrix asVMTFMatrix.
]

{ #category : #initialization }
VMICPBaseAlgotithm >> initialize [
	maxIterations := 30.
	sensorPointHistory := OrderedCollection new.
	useSensorPoint := true.
	self setup.
]

{ #category : #accessing }
VMICPBaseAlgotithm >> inputCollection: aPointCollection [
	collectionHistory add: aPointCollection
]

{ #category : #'basic algorithm' }
VMICPBaseAlgotithm >> iterateOnce [
	"performs a single iteration of the main loop"
	
	"1) create matching pairs"
	self createMatchPairs.
	
	"2) determine inliners/outliers"
	self markOutliers.
	
	"3) compute transformation"
	self computeTransformation.
	
	"4) apply Transformation"
	self applyTransform.
	

]

{ #category : #accessing }
VMICPBaseAlgotithm >> iterationCount [
	"note: we start with 0, and only increment after each iteration (in #applyTransform)"
	^ collectionHistory size
]

{ #category : #'basic algorithm' }
VMICPBaseAlgotithm >> loop [
	"check abort conditions and continue/return"
	[ self checkAbortCondition ] whileFalse: [
		self iterateOnce.
	].
	
	"we compute matching pairs one more time to compute the final square error"
	self createMatchPairs.
	self markOutliers.
]

{ #category : #'pair matching & outlier detection' }
VMICPBaseAlgotithm >> markOutliers [
	self subclassResponsibility
]

{ #category : #accessing }
VMICPBaseAlgotithm >> matchHistory [
	^ matchHistory
]

{ #category : #accessing }
VMICPBaseAlgotithm >> maxIterations [
	^maxIterations
]

{ #category : #accessing }
VMICPBaseAlgotithm >> maxIterations: aNumber [
	maxIterations := aNumber.
]

{ #category : #accessing }
VMICPBaseAlgotithm >> nnCollection [
	^ nnCollection
]

{ #category : #accessing }
VMICPBaseAlgotithm >> nnCollection: collection [
	nnCollection := collection asNNCollection.
	"nnCollection := collection asVMQuadTree2."
]

{ #category : #accessing }
VMICPBaseAlgotithm >> sensorPoint [
	^ sensorPointHistory first
]

{ #category : #accessing }
VMICPBaseAlgotithm >> sensorPoint: aPoint [
	sensorPointHistory add: aPoint.
]

{ #category : #accessing }
VMICPBaseAlgotithm >> sensorPointHistory [
	^ sensorPointHistory
]

{ #category : #'basic algorithm' }
VMICPBaseAlgotithm >> setup [
	collectionHistory := OrderedCollection new.
	tfHistory := OrderedCollection new.
	matchHistory := OrderedCollection new.
]

{ #category : #accessing }
VMICPBaseAlgotithm >> tfHistory [
	^tfHistory
]

{ #category : #accessing }
VMICPBaseAlgotithm >> useSensorPoint [
	^ useSensorPoint
]

{ #category : #accessing }
VMICPBaseAlgotithm >> useSensorPoint: aBoolean [
	useSensorPoint := aBoolean.
]
