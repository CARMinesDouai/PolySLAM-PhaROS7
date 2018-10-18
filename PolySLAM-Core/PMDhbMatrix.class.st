Class {
	#name : #PMDhbMatrix,
	#superclass : #Object,
	#instVars : [
		'rows',
		'lupDecomposition'
	],
	#category : #'PolySLAM-Core-LinAlgebra'
}

{ #category : #creation }
PMDhbMatrix class >> join: anArrayOfMatrices [
		"Inverse of the split operation.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 8/5/99 "
	| rows n row rowSize n1 n2 |
	rows := OrderedCollection new.
	n1 := ( anArrayOfMatrices at: 1) numberOfColumns.
	n2 := n1 + 1.
	rowSize := n1 + ( anArrayOfMatrices at: 2) numberOfColumns.
	n := 0.
	( anArrayOfMatrices at: 1) rowsDo:
		[ :each |
		  n := n + 1.
		  row := DhbVector new: rowSize.
		  row replaceFrom: 1 to: n1 with: each startingAt: 1;
			  replaceFrom: n2 to: rowSize with: ( ( anArrayOfMatrices at: 2) rowAt: n) startingAt: 1.
		  rows add: row.
		].
	n := 0.
	( anArrayOfMatrices at: 3) rowsDo:
		[ :each |
		  n := n + 1.
		  row := DhbVector new: rowSize.
		  row replaceFrom: 1 to: n1 with: each startingAt: 1;
			  replaceFrom: n2 to: rowSize with: ( ( anArrayOfMatrices at: 4) rowAt: n) startingAt: 1.
		  rows add: row.
		].
	^self rows: rows
]

{ #category : #information }
PMDhbMatrix class >> lupCRLCriticalDimension [
		"(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 6/5/99 "
	^40
]

{ #category : #creation }
PMDhbMatrix class >> new: anInteger [
		"Create an empty square matrix of dimension anInteger.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 11/2/99 "
	^self new initialize: anInteger
]

{ #category : #creation }
PMDhbMatrix class >> rows: anArrayOrVector [
		"Create a new matrix with given components.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 11/2/99 "
	^self new initializeRows: anArrayOrVector
]

{ #category : #'as yet unclassified' }
PMDhbMatrix class >> rows: rows columns: columns [
	"Answer a new Matrix of the given dimensions filled with random numbers"
	|a b|
	a:=	(1 to: rows) collect: [:row |b:=DhbVector new:columns .
		1 to: columns do: [:column |
			b  at: column put: 0].
		b].
	^DhbMatrix rows: a
]

{ #category : #operation }
PMDhbMatrix >> * aNumberOrMatrixOrVector [
	"Answers the product of the receiver with the argument. The argument can be a number, matrix or vector."
	^ aNumberOrMatrixOrVector productWithMatrix: self
]

{ #category : #operation }
PMDhbMatrix >> + aMatrix [
	"Answers the sum of the receiver with aMatrix."
	^ aMatrix addWithRegularMatrix: self
]

{ #category : #operation }
PMDhbMatrix >> - aMatrix [
	"Answers the difference between the receiver and aMatrix."
	^ aMatrix subtractWithRegularMatrix: self
]

{ #category : #comparing }
PMDhbMatrix >> = aNumberOrMatrix [ 
	^ (aNumberOrMatrix species = self species) and: [ self rows = aNumberOrMatrix rows ]
]

{ #category : #'double dispatching' }
PMDhbMatrix >> adaptToNumber: rcvr andSend: selector [
	"selector must obviously be commutative for this simple solution, but at the moment its only used for multiplication"
	^ self perform:  selector with: rcvr.
]

{ #category : #'double dispatching' }
PMDhbMatrix >> addWithRegularMatrix: aMatrix [
	"Answers the sum of the receiver with aMatrix as a DhbMatrix."
	| n |
	n := 0.
	^ DhbMatrix rows: ( self rowsCollect: [ :each | n := n + 1. each + ( aMatrix rowAt: n)])
]

{ #category : #'double dispatching' }
PMDhbMatrix >> addWithSymmetricMatrix: aMatrix [
	^ aMatrix addWithRegularMatrix: self 
]

{ #category : #transformation }
PMDhbMatrix >> asSymmetricMatrix [
	"Convert the receiver to a symmetric matrix (no check is made)."
	^ DhbSymmetricMatrix rows: rows
]

{ #category : #'cell accessing' }
PMDhbMatrix >> at: aRowIndex at: aColumnIndex [
	"Answers the aRowIndex-th, aColumnIndex-th entry in the receiver."
	^ self rowAt: aRowIndex columnAt: aColumnIndex
]

{ #category : #'cell accessing' }
PMDhbMatrix >> at: rowIndex at: columnIndex put: value [

	self rowAt: rowIndex columnAt: columnIndex put: value
	

]

{ #category : #'cell accessing' }
PMDhbMatrix >> atColumn: anInteger [

	^ self columnAt: anInteger
]

{ #category : #'cell accessing' }
PMDhbMatrix >> atColumn: aColumnIndex put: aCollection [

	aCollection withIndexDo: [: value : rowIndex |
		self rowAt: rowIndex columnAt: aColumnIndex put: value ]
	

]

{ #category : #'cell accessing' }
PMDhbMatrix >> atColumn: aColumnNumber put: aCollection startingAt: rowNumber [
	" Fill the receiver with aCollection at aColumnNumber begining at rowNumber. "
	
	aCollection withIndexDo: [: value : rowIndex |
		(rowIndex + rowNumber ) <= self numberOfRows 
		ifTrue: 
		[ self rowAt: rowIndex + rowNumber
			columnAt: aColumnNumber 
			put: value ]]
	

]

{ #category : #'cell accessing' }
PMDhbMatrix >> atRow: rowIndex put: aCollection [

	aCollection withIndexDo: [: value : columnIndex |
		self rowAt: rowIndex columnAt: columnIndex put: value ]
	

]

{ #category : #'cell accessing' }
PMDhbMatrix >> atRow: rowIndex put: aCollection startingAt: startColumnNumber [ 
	"Fill the receiver with aCollection at rowIndex beggining at startColumnNumber. "
		
	aCollection withIndexDo: [: value : columnIndex |
		(columnIndex + startColumnNumber ) <= self numberOfColumns 
		ifTrue:
		[ self 
			rowAt: rowIndex 
			columnAt: columnIndex + startColumnNumber
			put: value ]]
	

]

{ #category : #'cell accessing' }
PMDhbMatrix >> columnAt: anInteger [
	"Answers the anInteger-th column of the receiver."
	^ rows collect: [ :each | each at: anInteger ]
]

{ #category : #iterators }
PMDhbMatrix >> columnsCollect: aBlock [
	"Perform the collect: operation on the rows of the receiver."
	| n |
	n := 0.
	^ rows last collect: [ :each | n := n + 1. aBlock value: (self columnAt: n)]
]

{ #category : #iterators }
PMDhbMatrix >> columnsDo: aBlock [
	"Perform the collect: operation on the rows of the receiver."
	| n |
	n := 0.
	^ rows last do: [ :each | n := n + 1. aBlock value: ( self columnAt: n)]
]

{ #category : #accessing }
PMDhbMatrix >> determinant [
	^ self lupDecomposition determinant
]

{ #category : #accessing }
PMDhbMatrix >> dimension [

	^ self rows size @ (self rows at: 1) size
]

{ #category : #comparing }
PMDhbMatrix >> hash [
	^ rows hash
]

{ #category : #iterators }
PMDhbMatrix >> indicesDo: aBlock [
	1 to: rows size do:
		[ :rowIndex | 1 to: (rows at: rowIndex) size do: [ :columnIndex | aBlock value: rowIndex value: columnIndex ] ]
]

{ #category : #initialization }
PMDhbMatrix >> initialize: anInteger [
	"Build empty components for a square matrix. No check is made: components are assumed to be orgainized in rows."
	rows := (1 to: anInteger) asDhbVector collect: [ :each | DhbVector new: anInteger].
]

{ #category : #initialization }
PMDhbMatrix >> initializeRows: anArrayOrVector [
	"Defines the components of the recevier. No check is made: components are assumed to be orgainized in rows."
	rows := anArrayOrVector asDhbVector collect: [ :each | each asDhbVector].
]

{ #category : #operation }
PMDhbMatrix >> inverse [
	"Answer the inverse of the receiver."

	^ self isSquare 
		ifTrue: [ self lupInverse ]
		ifFalse: [ self squared inverse * self transpose ]
]

{ #category : #operation }
PMDhbMatrix >> inversePureCRL [
	"Answer the inverse of the receiver."
	^ self squared inversePureCRL * self transpose
]

{ #category : #testing }
PMDhbMatrix >> isSquare [
	"Answers true if the number of rows is equal to the number of columns."
	^ rows size = rows last size
]

{ #category : #testing }
PMDhbMatrix >> isSymmetric [
	^ self = self transpose 
]

{ #category : #private }
PMDhbMatrix >> largestPowerOf2SmallerThan: anInteger [
	"Private - "
	| m m2|
	m := 2.
	[ m2 := m * 2.
	  m2 < anInteger] whileTrue:[ m := m2].
	^m
]

{ #category : #accessing }
PMDhbMatrix >> lupDecomposition [

	lupDecomposition isNil
		ifTrue: [ lupDecomposition :=DhbLUPDecomposition equations: rows ].
	^ lupDecomposition
]

{ #category : #operation }
PMDhbMatrix >> lupInverse [
	self lupDecomposition inverseMatrixComponents 
		ifNil: [ SingularMatrixError new signal ] 
		ifNotNilDo: [ :i| ^self class rows:i ].

]

{ #category : #transformation }
PMDhbMatrix >> negate [
	"Inverse the sign of all components of the receiver."
	rows do: [ :each |each negate ]
]

{ #category : #accessing }
PMDhbMatrix >> numberOfColumns [
	"Answer the number of rows of the receiver."
	^ rows last size
]

{ #category : #accessing }
PMDhbMatrix >> numberOfRows [
	"Answer the number of rows of the receiver."
	^ rows size
]

{ #category : #printing }
PMDhbMatrix >> printOn: aStream [
	(rows isNil or: [rows first isNil])
		ifTrue: [ super printOn: aStream. 
					aStream nextPutAll:'(uninitialized)'. ^ self ].
	rows 
		do: [ :each | each printOn: aStream]
		separatedBy: [ aStream cr].
		  
		
]

{ #category : #private }
PMDhbMatrix >> privateTranspose [
	^ self transpose 
]

{ #category : #'double dispatching' }
PMDhbMatrix >> productWithMatrix: aMatrix [
	"Answers the product of aMatrix with the receiver (in this order)."
	^ self productWithMatrixFinal: aMatrix
]

{ #category : #'double dispatching' }
PMDhbMatrix >> productWithMatrixFinal: aMatrix [
	"Answers the product of aMatrix with the receiver (in this order)."
	"speed optimized"
	|t|
	t :=self privateTranspose.
	^ DhbMatrix  rows: ( aMatrix rowsCollect: [ :row | t rowsCollect: [ :col | row * col]])
]

{ #category : #'double dispatching' }
PMDhbMatrix >> productWithTransposeMatrix: aMatrix [
	"Answers the product of the receiver with the transpose of aMatrix(in this order)."
	^ DhbMatrix rows: (self rowsCollect: [ :row | aMatrix rowsCollect: [ :col | row * col]])
]

{ #category : #'double dispatching' }
PMDhbMatrix >> productWithVector: aVector [
	"Answers the product of the receiver with aVector"
	^ self columnsCollect: [ :each | each * aVector ]
]

{ #category : #'cell accessing' }
PMDhbMatrix >> rowAt: anInteger [
	"Answers the anInteger-th row of the receiver."
	^ rows at: anInteger
]

{ #category : #'cell accessing' }
PMDhbMatrix >> rowAt: aRowIndex columnAt: aColumnIndex [
	"Answers the aRowIndex-th, aColumnIndex-th entry in the receiver."
	^ (rows at: aRowIndex) at: aColumnIndex
]

{ #category : #'cell accessing' }
PMDhbMatrix >> rowAt: aRowIndex columnAt: aColumnIndex put: aValue [
	
	^(rows at: aRowIndex) at: aColumnIndex put: aValue
]

{ #category : #'cell accessing' }
PMDhbMatrix >> rows [
	^rows
]

{ #category : #iterators }
PMDhbMatrix >> rowsCollect: aBlock [
	"Perform the collect: operation on the rows of the receiver."
	^ rows collect: aBlock
]

{ #category : #iterators }
PMDhbMatrix >> rowsDo: aBlock [
	"Perform the collect: operation on the rows of the receiver."
	^ rows do: aBlock
]

{ #category : #transformation }
PMDhbMatrix >> scaleBy: aNumber [

	rows do: [ :each | each scaleBy: aNumber ]
]

{ #category : #private }
PMDhbMatrix >> species [
	^ DhbMatrix 
]

{ #category : #private }
PMDhbMatrix >> split [
	"Private - Answers an array of 4 matrices split from the receiver."
	| n m n1 m1 |
	n := self numberOfRows.
	m := self numberOfColumns.
	n1 := self largestPowerOf2SmallerThan: n.
	m1 := self largestPowerOf2SmallerThan: m.
	^ Array
		with: ( self class rows: ( ( 1 to: n1) asDhbVector collect: [ :k | ( rows at: k) copyFrom: 1 to: m1]))
		with:( self class rows: ( ( 1 to: n1) asDhbVector collect: [ :k | ( rows at: k) copyFrom: (m1 + 1) to: m]))
		with: ( self class rows: ( ( (n1 + 1) to: n) asDhbVector collect: [ :k | ( rows at: k) copyFrom: 1 to: m1]))
		with:( self class rows: ( ( (n1 + 1) to: n) asDhbVector collect: [ :k | ( rows at: k) copyFrom: (m1 + 1) to: m]))
]

{ #category : #operation }
PMDhbMatrix >> squared [
	| transposed |
	transposed :=self privateTranspose.
	^ DhbSymmetricMatrix 
		new: transposed numberOfRows 
		function: [ :x :y|(transposed rowAt: x) * (transposed rowAt: y) ]

]

{ #category : #private }
PMDhbMatrix >> strassenProductWithMatrix: aMatrix [
	"Private"
	| matrixSplit selfSplit p1 p2 p3 p4 p5 p6 p7 |
	( self numberOfRows > 2 and: [ self numberOfColumns > 2])
		ifFalse:[ ^self class rows: ( aMatrix rowsCollect: [ :row | self columnsCollect: [ :col | row * col]])].
	selfSplit := self split.
	matrixSplit := aMatrix split.
	p1 := ( ( selfSplit at: 2) - ( selfSplit at: 4)) strassenProductWithMatrix: ( matrixSplit at: 1).
	p2 := ( selfSplit at: 4) strassenProductWithMatrix: ( ( matrixSplit at: 1) + ( matrixSplit at: 2)).
	p3 := ( selfSplit at: 1) strassenProductWithMatrix: ( ( matrixSplit at: 3) + ( matrixSplit at: 4)).
	p4 := ( ( selfSplit at: 3) - ( selfSplit at: 1)) strassenProductWithMatrix: ( matrixSplit at: 4).
	p5 := ( ( selfSplit at: 1) + ( selfSplit at: 4)) strassenProductWithMatrix: ( ( matrixSplit at: 1) + ( matrixSplit at: 4)).
	p6 := ( ( selfSplit at: 3) + ( selfSplit at: 4)) strassenProductWithMatrix: ( ( matrixSplit at: 2) - ( matrixSplit at: 4)).
	p7 := ( ( selfSplit at: 1) + ( selfSplit at: 2)) strassenProductWithMatrix: ( ( matrixSplit at: 1) - ( matrixSplit at: 3)).
	^self class join: ( Array
							with: ( p5 + p4 + p6 - p2)
							with: (p1 + p2)
							with: ( p3 + p4)
							with: ( p5 + p1 - p3 - p7)
							)
]

{ #category : #'double dispatching' }
PMDhbMatrix >> subtractWithRegularMatrix: aMatrix [
	"Answers the difference between aMatrix and the receiver as a Matrix."
	| n |
	n := 0.
	^ DhbMatrix rows: ( aMatrix rowsCollect: [ :each | n := n + 1. each - ( self rowAt: n)])
]

{ #category : #'double dispatching' }
PMDhbMatrix >> subtractWithSymmetricMatrix: aMatrix [
	"Answers the difference between aMatrix and the receiver."
	^ self subtractWithRegularMatrix: aMatrix 
]

{ #category : #operation }
PMDhbMatrix >> transpose [
	"Answer a new matrix, transpose of the receiver."
	^ self class rows: ( self columnsCollect: [ :each | each])
]

{ #category : #'double dispatching' }
PMDhbMatrix >> transposeProductWithMatrix: aMatrix [
	"Answers the product of the transpose of the receiver with aMatrix (in this order)."
	"speed optimized"
	|t|
	t :=aMatrix privateTranspose.
	^ DhbMatrix rows: (self columnsCollect: [ :row | t rowsCollect: [ :col | row * col]])
]
