Class {
	#name : #VMLineFittingErrorComputer,
	#superclass : #Object,
	#instVars : [
		'errorCollection'
	],
	#category : #'PolySLAM-Core-Line- & Vector Approximation'
}

{ #category : #'as yet unclassified' }
VMLineFittingErrorComputer class >> compute: aVectorCollection line: aline [
	^(self new)
		compute: aVectorCollection line: aline;
		yourself.
]

{ #category : #'as yet unclassified' }
VMLineFittingErrorComputer >> compute: aVectorCollection line: aLine [
	| line |
	line := aLine asVMLine.
	errorCollection := aVectorCollection
		collect: [ :vec | self computeErrorVector: vec line: line ]
		as: VMRenderCollection.
	
	^errorCollection.
]

{ #category : #'as yet unclassified' }
VMLineFittingErrorComputer >> computeErrorVector: aVector line: aLine [
	^(aLine squareDistanceToPoint: aVector pointA) +
		(aLine squareDistanceToPoint: aVector pointB)
]

{ #category : #'as yet unclassified' }
VMLineFittingErrorComputer >> errorCollection [
	^errorCollection
]
