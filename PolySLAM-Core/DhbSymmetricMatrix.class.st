Class {
	#name : #DhbSymmetricMatrix,
	#superclass : #DhbMatrix,
	#category : #'PolySLAM-Core-LinAlgebra'
}

{ #category : #'instance creation' }
DhbSymmetricMatrix class >> identity: anInteger [
		"Create an identity matrix of dimension anInteger"
	^self new initializeIdentity: anInteger
]

{ #category : #'instance creation' }
DhbSymmetricMatrix class >> join: anArrayOfMatrices [
		"Inverse of the split operation"
	| rows n |
	rows := OrderedCollection new.
	n := 0.
	( anArrayOfMatrices at: 1) rowsDo:
		[ :each |
		  n := n + 1.
		  rows add: each, ( ( anArrayOfMatrices at: 3) columnAt: n).
		].
	n := 0.
	( anArrayOfMatrices at: 2) rowsDo:
		[ :each |
		  n := n + 1.
		  rows add: ( ( anArrayOfMatrices at: 3) rowAt: n), each.
		].
	^self rows: rows
]

{ #category : #information }
DhbSymmetricMatrix class >> lupCRLCriticalDimension [
	^36
]

{ #category : #'instance creation' }
DhbSymmetricMatrix class >> new: dim function: aBlock [
"Answer a new symmetric matrix with dimensions dim filled with 
aBlock value: RowposRespectivelyColpos value: ColposRespectivelyRowpos"
	|a aRow|
	a:=self new basicInitialize: dim.
	aRow := DhbVector new: dim.
	1 to: dim do:[:i|aRow at: i put: (aBlock value: i value:1)].
	a rows at: 1 put: aRow.
	2 to: dim do: [:rowPos|
		aRow :=DhbVector new: dim .
		1 to: rowPos -1 do:[:pos| aRow at: pos put: ((a rows at: pos) at: rowPos)].
		rowPos to: dim do:[:pos| aRow at: pos put: (aBlock value: rowPos value:pos)]. 
		(a rows) at: rowPos put: aRow ].    
	^a 
]

{ #category : #operation }
DhbSymmetricMatrix >> + aMatrix [
	"Answers the sum of the receiver with aMatrix."
	^ aMatrix addWithSymmetricMatrix: self
]

{ #category : #operation }
DhbSymmetricMatrix >> - aMatrix [
	"Answers the difference between the receiver and aMatrix"
	^ aMatrix subtractWithSymmetricMatrix: self
]

{ #category : #'double dispatching' }
DhbSymmetricMatrix >> addWithSymmetricMatrix: aMatrix [
	^self class 
		new: aMatrix numberOfRows 
		function: [ :x :y|((rows at:x)at:y)+((aMatrix rows at:x)at:y) ]

]

{ #category : #transformation }
DhbSymmetricMatrix >> asSymmetricMatrix [
"simple speed up"
^self
]

{ #category : #information }
DhbSymmetricMatrix >> atColumn: aColumnIndex put: aCollection [
	self shouldNotImplement 
]

{ #category : #information }
DhbSymmetricMatrix >> atRow: aRowIndex put: aCollection [
	self shouldNotImplement 
]

{ #category : #initialization }
DhbSymmetricMatrix >> basicInitialize: anInteger [
	"private"
	rows := DhbVector new: anInteger.
]

{ #category : #initialization }
DhbSymmetricMatrix >> clear [
	
	rows do: [ :each | each atAllPut: 0].
]

{ #category : #information }
DhbSymmetricMatrix >> columnAt: anInteger [
	^ rows at: anInteger   
]

{ #category : #iterators }
DhbSymmetricMatrix >> columnsCollect: aBlock [
	^ rows collect: aBlock 
]

{ #category : #iterators }
DhbSymmetricMatrix >> columnsDo: aBlock [
	^ rows do: aBlock 
]

{ #category : #operation }
DhbSymmetricMatrix >> crlInverse [
	"corrected sequence of calcs; s1in matrices at:2 has to be calced first (split returns matrices in this order: b, d, c).
and taken care of degenerate cases (which is unnecessary, if this method is not called outside of inverse)"
	| matrices b1 cb1ct cb1 |
	rows size = 1
		ifTrue: [ ^self inverse1By1].
	rows size = 2
		ifTrue: [ ^self inverse2By2].
	matrices := self split.
	b1 := (matrices at: 1) inverse.
	cb1 := (matrices at: 3) * b1.
	cb1ct := (cb1 productWithTransposeMatrix: (matrices at: 3))asSymmetricMatrix .
	matrices at: 2 put: ((matrices at: 2) - cb1ct ) inverse.
	matrices at: 3 put: (matrices at: 2) * cb1.
	matrices at: 1 put: ( b1 + (cb1 transposeProductWithMatrix: (matrices at: 3))asSymmetricMatrix).
	(matrices at: 3) negate.
	^ self class join: matrices
]

{ #category : #initialization }
DhbSymmetricMatrix >> initializeIdentity: anInteger [
	"Build components for an identity matrix."
	rows := ( 1 to: anInteger) asDhbVector collect: [ :n | (DhbVector new: anInteger) atAllPut: 0; at: n put: 1; yourself].
]

{ #category : #operation }
DhbSymmetricMatrix >> inverse [
	"Answer the inverse of the receiver"

	^(rows size < self class lupCRLCriticalDimension or: [lupDecomposition notNil]) 
			ifTrue: [ self lupInverse ]
			ifFalse: [ self crlInverse ]
]

{ #category : #operation }
DhbSymmetricMatrix >> inverse1By1 [
	"Private - Answer the inverse of the receiver when it is a 1x1 matrix (no check is made)."
	^ self class rows: ( DhbVector with: ( DhbVector with: ( 1/ ((rows at: 1) at: 1))))
]

{ #category : #operation }
DhbSymmetricMatrix >> inverse2By2 [
	"Private - Answer the inverse of the receiver when it is a 2x2 matrix (no check is made)."
	| line1 line2 |
	line1 := DhbVector with: ((rows at: 2) at: 2) with: ((rows at: 1) at: 2) negated.
	line2 := DhbVector with: ((rows at: 1) at: 2) negated with: ((rows at: 1) at: 1).
	^self class rows: ( DhbVector with: line1 with: line2) * (1 / (((rows at: 1) at: 1) * ((rows at: 2) at: 2) - ((rows at: 1) at: 2) squared))
]

{ #category : #operation }
DhbSymmetricMatrix >> inversePureCRL [
	"Answer the inverse of the receiver."
	| matrices b1 cb1 cb1ct |
	[rows size = 1
		ifTrue: [ ^self inverse1By1]]on: ZeroDivide do: [:e| e signal "SingularMatrixError new signal"].
	rows size = 2
		ifTrue: [ ^ self inverse2By2].
	matrices := self split.
	b1 := (matrices at: 1) inversePureCRL.
	cb1 := (matrices at: 3) * b1.
	cb1ct := (cb1 productWithTransposeMatrix: ( matrices at: 3)) asSymmetricMatrix.
	matrices at: 2 put: ((matrices at: 2) - cb1ct) inversePureCRL.
	matrices at: 3 put: (matrices at: 2) * cb1.
	matrices at: 1 put: (b1 + ( cb1 transposeProductWithMatrix: ( matrices at: 3))asSymmetricMatrix).
	(matrices at: 3) negate.
	^ self class join: matrices
]

{ #category : #operation }
DhbSymmetricMatrix >> inversePureLUP [
	"Answer the inverse of the receiver."
	lupDecomposition := nil.
	self lupDecomposition inverseMatrixComponents 
		ifNil: [ self error: 'singular matrix error'"SingularMatrixError new signal" ] 
		ifNotNilDo: [ :i| ^self class rows: i ].

]

{ #category : #testing }
DhbSymmetricMatrix >> isSquare [
	"Answers true because a symmetric matrix is square."
	^true
]

{ #category : #testing }
DhbSymmetricMatrix >> isSymmetric [
		"Answers true because the receiver is a symmetric matrix"
	^true
]

{ #category : #information }
DhbSymmetricMatrix >> numberOfColumns [
	"Answer the number of columns of the receiver."
	^rows size
]

{ #category : #'private ' }
DhbSymmetricMatrix >> privateTranspose [ 
	^ self 
]

{ #category : #transformation }
DhbSymmetricMatrix >> split [
	"Private - 
	Answers an array of 3 matrices split from the receiver"

	| n |
	n := self largestPowerOf2SmallerThan: rows size.
	^Array
		with: (self class rows: ((1 to: n) asDhbVector collect: [:k | (rows at: k)
						copyFrom: 1 to: n]))
		with: (self class rows: ((n + 1 to: rows size) asDhbVector collect: [:k | (rows at: k)
						copyFrom: n + 1 to: rows size]))
		with: (self class superclass rows: ((n + 1 to: rows size) asDhbVector collect: [:k | (rows at: k)
						copyFrom: 1 to: n]))
]

{ #category : #'double dispatching' }
DhbSymmetricMatrix >> subtractWithSymmetricMatrix: aMatrix [
	^ self class 
		new: aMatrix numberOfRows 
		function: [ :x :y|((aMatrix rows at:x)at:y)-(( rows at:x)at:y) ]
]

{ #category : #information }
DhbSymmetricMatrix >> transpose [
	"Answer a new matrix, transpose of the receiver. optimized"
	^self deepCopy
]
