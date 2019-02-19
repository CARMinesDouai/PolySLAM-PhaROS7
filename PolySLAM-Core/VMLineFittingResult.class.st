"
contains the result of a vector chain  approximation:
	- vectorCollection: the vectors that are approximated (i.e. 'inliers')
	- errorCollection: the error for each vector in respect of the approximating line
	- line: the line that is approximating the vector collection
	- lineHistory: used for visualization of the line fitting process. serves no further purpose
	
additional functionality:
	- computeVector
		returns a single vector that spans the full inlier collection. note, that the new vector's  start/end points
		typically do not match any points in the original colletion. note, that we usually don't make use of this
		method when simplifying polygons, since it ignores information about preceeding and following line segments
		of the polygon.
	- reduceToSingleChain
		removes elements from the inlier collection, so that all remaining elements are connected in a single
		chain of vectors. the chain typically does not form a closed polygon.
"
Class {
	#name : #VMLineFittingResult,
	#superclass : #Object,
	#instVars : [
		'vectorCollection',
		'errorCollection',
		'line',
		'lineHistory'
	],
	#category : #'PolySLAM-Core-Line- & Vector Approximation'
}

{ #category : #'as yet unclassified' }
VMLineFittingResult class >> rendererClass [
	^ VMFittingResultRenderer
]

{ #category : #'as yet unclassified' }
VMLineFittingResult class >> vectors: aVectorCollection errors: anErrorCollection line: aLine [
	^(self new)
		vectorCollection: aVectorCollection;
		errorCollection: anErrorCollection;
		line: aLine;
		checkLineOrientation;
		yourself
]

{ #category : #converting }
VMLineFittingResult >> asRenderableElement [
	^ self class rendererClass new model: self
]

{ #category : #accessing }
VMLineFittingResult >> bounds [
	^ vectorCollection bounds
]

{ #category : #'as yet unclassified' }
VMLineFittingResult >> checkLineOrientation [
	"if the provided line is orientated against the provided vector collection, we flip the orientation of the line"
	| baseVector deltaAngle |
	
	baseVector := vectorCollection first pointA vectorTo: vectorCollection last pointB.
	deltaAngle := line asVMLineSegment deltaAngle: baseVector.
	(deltaAngle between: Float halfPi negated and: Float halfPi) ifTrue: [ ^ self ].
	
	line := line reversed.
	
]

{ #category : #public }
VMLineFittingResult >> computeVector [
	| start stop |
	
	line ifNil: [ ^nil ].
	
	start := line projectionPoint: vectorCollection first pointA.
	stop := line projectionPoint: vectorCollection last pointB.
	
	^VMLineSegment from: start to: stop type: vectorCollection first type.
	
]

{ #category : #accessing }
VMLineFittingResult >> errorCollection [
	^errorCollection
]

{ #category : #accessing }
VMLineFittingResult >> errorCollection: aCollection [
	errorCollection := aCollection.
]

{ #category : #'GT Inspector' }
VMLineFittingResult >> gtInspectorRenderedIn: composite [
	<gtInspectorPresentationOrder: 50>
	
	(composite morph)
		title: 'Viewer';
		morph: [
			(VMViewer openWindowlessOn: { self asRenderableElement })
				autozoom.
		].
		
]

{ #category : #initialization }
VMLineFittingResult >> initialize [
	line := nil.
	vectorCollection := OrderedCollection new.
	errorCollection := OrderedCollection new.
	lineHistory := OrderedCollection new.
]

{ #category : #accessing }
VMLineFittingResult >> line [
	^line
]

{ #category : #accessing }
VMLineFittingResult >> line: aLine [
	line := aLine.
]

{ #category : #accessing }
VMLineFittingResult >> lineHistory [
	^ lineHistory
]

{ #category : #public }
VMLineFittingResult >> reduceToSingleChain [
	"creates a copy that contains only a single vector chain in vectorCollection"
	| vectorChains errorChains newResult max maxIndex |
	
	vectorChains := OrderedCollection new.
	vectorChains add: OrderedCollection new.
	errorChains := OrderedCollection new.
	errorChains add: OrderedCollection new.
	newResult := self species new.
	
	vectorChains first add: vectorCollection first.
	errorChains first add: errorCollection first.
	
	"create collection of chains"
	2 to: vectorCollection size do: [ :index |
		(vectorCollection at: index) pointA = (vectorChains last last pointB)
			ifFalse: [ vectorChains add: OrderedCollection new. errorChains add: OrderedCollection new. ].
		vectorChains last add: (vectorCollection at: index).
		errorChains last add: (errorCollection at: index).
	].
	
	"pick the biggest chain"
	max := 0.
	maxIndex := 0.
	vectorChains doWithIndex: [ :chain :index |
		(max < chain size) ifTrue: [ max := chain size. maxIndex := index ].
	].
	
	newResult vectorCollection: (vectorChains at: maxIndex).
	newResult errorCollection: (errorChains at: maxIndex).
	newResult line: self line.
	
	^newResult

]

{ #category : #accessing }
VMLineFittingResult >> score [
	"computes a score value for the result. the score benefits larger collections of inliers
	(when the average error stays the same) and lower average error (if the inlier count is
	the same)."
	| averageSquareError size |
	vectorCollection ifEmpty: [ ^ 0 ].
	
	size := vectorCollection size.
	averageSquareError := (errorCollection reduce: [ :a :b | a + b ]) / size.
	
	"averageSquareError = 0 ifTrue: [ ^ 1 ]."
	
	"debug message"
	"Transcript
		show: self class printString, ' score -- size=';
		show: size printString, ' avgSquareError=', averageSquareError printString;
		show: ' score=', ((size / (size + 3)) / averageSquareError) printString; cr.
	"
	^ ((size / (size + 1)) ** 8) / (averageSquareError + 0.0001)
]

{ #category : #accessing }
VMLineFittingResult >> vectorCollection [
	^vectorCollection
]

{ #category : #accessing }
VMLineFittingResult >> vectorCollection: aCollection [
	vectorCollection := aCollection.
]
