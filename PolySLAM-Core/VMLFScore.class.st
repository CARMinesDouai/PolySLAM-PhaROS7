"
This class is reposnsible to compute the score for a VMLineFittingResult. Three parameters (named a, b, and c) are available to invluence the resulting score.

Note: see #size:error: for what the parameter a, b, and c do.

- scoreForResult: <VMLineFittingResult>
	computes the score for the provided result by forwarding size and error to #size:error:
- size: <anInteger> error: <averageSquareError>
	computes the score for the provided data
 

"
Class {
	#name : #VMLFScore,
	#superclass : #Object,
	#instVars : [
		'a',
		'b',
		'c'
	],
	#category : #'PolySLAM-Core-Line- & Vector Approximation'
}

{ #category : #'as yet unclassified' }
VMLFScore class >> a: paramA b: paramB c: paramC [
	^ self new
		a: paramA;
		b: paramB;
		c: paramC;
		yourself
]

{ #category : #accessing }
VMLFScore >> a [
	^ a
]

{ #category : #accessing }
VMLFScore >> a: aNumber [
	a := aNumber.
]

{ #category : #accessing }
VMLFScore >> a: paramA b: paramB c: paramC [
	a := paramA.
	b := paramB.
	c := paramC.
]

{ #category : #accessing }
VMLFScore >> b [
	^ b
]

{ #category : #accessing }
VMLFScore >> b: aNumber [
	b := aNumber.
]

{ #category : #accessing }
VMLFScore >> c [
	^ c
]

{ #category : #accessing }
VMLFScore >> c: aNumber [
	c := aNumber.
]

{ #category : #initialization }
VMLFScore >> initialize [
	a := 1.
	b := 4.
	c := 0.001.
]

{ #category : #printing }
VMLFScore >> printParameters [
	^ 'a=', a printString,
		', b=', b printString,
		', c=', c printString
]

{ #category : #'computing score' }
VMLFScore >> scoreForResult: aVMLineFittingResult [
	^ self size: aVMLineFittingResult vectorCollection size error: aVMLineFittingResult averageSquareError
]

{ #category : #'computing score' }
VMLFScore >> size: size error: error [
	"note (1): error reffers to the average error, not the total error
	note (2): error is expected to be zero or greater. typically we use the average square error."
	^ ( size / (size + a)) ** b  /  (error + c)
]
