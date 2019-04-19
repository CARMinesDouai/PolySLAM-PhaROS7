Class {
	#name : #PSEdgeApproximator,
	#superclass : #DoubleLink,
	#instVars : [
		'segments',
		'from',
		'to',
		'approxLine',
		'score'
	],
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #accessing }
PSEdgeApproximator >> approxLine [
	^ approxLine
]

{ #category : #approximation }
PSEdgeApproximator >> approximate [
	"calculate the approximate line + its overal error"
]

{ #category : #accessing }
PSEdgeApproximator >> from [
	^ from
]

{ #category : #initialization }
PSEdgeApproximator >> initialize [
	super initialize.
	segments := OrderedCollection new
]

{ #category : #accessing }
PSEdgeApproximator >> score [
	^ score
]

{ #category : #accessing }
PSEdgeApproximator >> segments [
	^ segments
]

{ #category : #accessing }
PSEdgeApproximator >> segments: anObject [
	segments := anObject
]

{ #category : #accessing }
PSEdgeApproximator >> to [
	^ to
]
