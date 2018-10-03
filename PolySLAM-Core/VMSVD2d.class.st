Class {
	#name : #VMSVD2d,
	#superclass : #Object,
	#instVars : [
		'u',
		's',
		'v'
	],
	#category : #'PolySLAM-Core-LinAlgebra'
}

{ #category : #creation }
VMSVD2d class >> matrix: m [
	^(self new)
		matrix: m;
		yourself.
]

{ #category : #computation }
VMSVD2d >> matrix: aDhbMatrix [
	"for the algorithm see:
		http://scicomp.stackexchange.com/questions/8899/robust-algorithm-for-2x2-svd
	"
	| m e f g h q r s1 s2 a1 a2 theta phi cosTheta sinTheta cosPhi sinPhi sign |
	m := aDhbMatrix.
	
	e := ((m at: 1 at: 1) + (m at: 2 at: 2)) * 0.5.
	f := ((m at: 1 at: 1) - (m at: 2 at: 2)) * 0.5.
	g := ((m at: 2 at: 1) + (m at: 1 at: 2)) * 0.5.
	h := ((m at: 2 at: 1) - (m at: 1 at: 2)) * 0.5.
	
	q := (e squared + h squared) sqrt.
	r := (f squared + g squared) sqrt.
	
	s1 := q + r.
	s2 := q - r.
	sign := (s2 >= 0.0) ifTrue: [ 1.0 ] ifFalse: [ self logCr: 'SVD neg. s2: ', s2 printString. -1.0 ].
	"sign := 1.0."
	
	a1 := ((g ~= 0.0) or: [f ~= 0])
		ifTrue: [g arcTan: f]
		ifFalse: [ Float halfPi * 0.5 ].
	a2 := ((h ~= 0.0) or: [e ~= 0])
		ifTrue: [ h arcTan: e ]
		ifFalse: [ Float halfPi * 0.5 ].
	
	theta := (a2 - a1) * 0.5.
	phi := (a2 + a1) * 0.5.
	
	cosPhi := phi cos.
	sinPhi := phi sin.
	cosTheta := theta cos.
	sinTheta := theta sin.
	
	"u := DhbMatrix rows: { {cosPhi. sinPhi negated * sign}. {sinPhi. cosPhi * sign} }.
	s := DhbMatrix rows: { {s1. 0}.  {0. s2 abs} }."
	u := DhbMatrix rows: { {cosPhi. sinPhi negated}. {sinPhi. cosPhi} }.
	s := DhbMatrix rows: { {s1. 0}.  {0. s2} }.
	v := (DhbMatrix rows: { {cosTheta. sinTheta negated}.  {sinTheta. cosTheta} }) transpose.

]

{ #category : #accessing }
VMSVD2d >> s [
	^s.
]

{ #category : #accessing }
VMSVD2d >> u [
	^u.
]

{ #category : #accessing }
VMSVD2d >> v [
	^v.
]
