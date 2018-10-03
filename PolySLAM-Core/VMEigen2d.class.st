"
I'm VMEigen2d, I compute the eigen values and eigen vectors of 2x2 matrices. I only support matrices with real eigen values (no imaginary number support).



Public API and Key Messages

- matrix (class side and instance side):
	computes the eigen values/vectors and stores them in the object (class side call returns a new instance)
	
- value1/2
	returns the first or second eigen-value. eigen values are not sorted
	
- vector1/2
	returns the eigen vector (as a Point object) to the corresponding eigen value


"
Class {
	#name : #VMEigen2d,
	#superclass : #Object,
	#instVars : [
		'eValue1',
		'eValue2',
		'eVec1',
		'eVec2',
		'det'
	],
	#category : #'PolySLAM-Core-LinAlgebra'
}

{ #category : #'as yet unclassified' }
VMEigen2d class >> matrix: m [
	^(self new)
		matrix: m;
		yourself.
]

{ #category : #accessing }
VMEigen2d >> det [
	"returns the determinant of the matrix"
	^det
]

{ #category : #creation }
VMEigen2d >> matrix: m [
	| a b c d trace tHalf tSquare epsilon |
	
	a := m at: 1 at: 1.
	b := m at: 1 at: 2.
	c := m at: 2 at: 1.
	d := m at: 2 at: 2.
	
	epsilon := 0.0000001.
	
	trace := a + d.
	tHalf := trace * 0.5.
	tSquare := trace squared.
	det := (a * d) - (b * c).
	
	eValue1 := tHalf + ( (tSquare / 4 - det) sqrt ).
	eValue2 := tHalf - ( (tSquare / 4 - det) sqrt ).
	
	(c abs > epsilon) ifTrue: [
		eVec1 := (eValue1 - d) @ c.
		eVec2 := (eValue2 - d) @ c.
	] ifFalse: [
		(b abs > epsilon) ifTrue: [
			eVec1 := b @ (eValue1 - a).
			eVec2 := b @ (eValue2 - a).
		] ifFalse: [
			eVec1 := 1@0.
			eVec2 := 0@1.
		].
	].
	
	eVec1 := eVec1 normalized.
	eVec2 := eVec2 normalized.

]

{ #category : #printing }
VMEigen2d >> printString [
	^'vector1=', eVec1 printString,
		', vector2=', eVec2 printString,
		', value1=', eValue1 printString,
		', value2=', eValue2 printString.
]

{ #category : #accessing }
VMEigen2d >> value1 [
	^eValue1
]

{ #category : #accessing }
VMEigen2d >> value2 [
	^eValue2
]

{ #category : #accessing }
VMEigen2d >> vector1 [
	^eVec1
]

{ #category : #accessing }
VMEigen2d >> vector2 [
	^eVec2
]
