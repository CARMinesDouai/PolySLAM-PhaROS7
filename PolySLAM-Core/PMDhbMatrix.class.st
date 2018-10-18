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

{ #category : #dbh }
PMDhbMatrix >> equalsTo: aMatrix [
	self rows 
			with: aMatrix rows  
			do: [:a :b| (a equalsTo: b) ifFalse: [ ^false ] ].
	^ true 
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

{ #category : #dbh }
PMDhbMatrix >> inversePivotColumns: anArray [
	"uses vector encoding of an interchange permutation matrix  in anArray as in qrFactorizationWithPivoting. Does inverse pivoting!"
	| res |
	res :=self deepCopy.
	anArray reverseWith: (1 to: anArray size ) do:  [ :piv :ind | piv ~= ind ifTrue: [res swapColumn: piv withColumn: ind ] ].
	^ res
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

{ #category : #dbh }
PMDhbMatrix >> mpInverse [
	"Moore Penrose Inverse. "
	|f g|
	self numberOfRows < self numberOfColumns 
		ifTrue:[	f := self transpose qrFactorizationWithPivoting. 
					g := f first.
					f := f second inversePivotColumns: (f at:3) ]
		ifFalse: [ f := self qrFactorizationWithPivoting. 
					g := (f second  inversePivotColumns: (f at:3)) transpose.
					f := f first transpose ]. 
	^ g * ((f *self *g) inverse) *f
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

{ #category : #dbh }
PMDhbMatrix >> orthogonalize [
	"returns an orthonormal basis of column (!) vectors for a matrix of column vectors"
	^ self qrFactorizationWithPivoting first

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

{ #category : #dbh }
PMDhbMatrix >> qrFactorization [
	|identMat q r hh colSize i|
	self numberOfRows < self numberOfColumns ifTrue:[ self error: 'numberOfRows<numberOfColumns' ]. 
	r :=DhbMatrix rows: (rows deepCopy).
	colSize := self numberOfRows.
	q := DhbSymmetricMatrix identity: colSize.  
	identMat := q deepCopy.
	1 to: self numberOfColumns do: [:col| 
		hh := ((r columnAt: col) copyFrom: col to: colSize) householder.
		i := (DhbVector new: col-1withAll: 0) , (hh at:2 ).
		q := q* (identMat - ((hh at: 1)*i tensorProduct: i ))."not really necessary, should be simplified"
		i := DhbMatrix rows:  ( (r rows allButFirst: (col -1)) collect: [:aRow| aRow allButFirst: (col -1)]  ).
		i := i - ((hh at: 2) tensorProduct: ( (hh at: 1)*(hh at: 2)*i  ) ) .
		i rows withIndexDo: [ :aRow :index |
			aRow  withIndexDo: [ :n :c| r rowAt: (col + index -1) columnAt: (col +c -1) put: ((n equalsTo: 0) ifTrue: [0] ifFalse:  [n]  )  ]  ] .
	"col <colSize ifTrue: [i :=(hh at: 2) copyFrom: 2 to: colSize -col +1.  i withIndexDo: [:n :index| r rowAt: col columnAt: index put: n  ]  ]""and this part is not correct, dont uncomment before the bug is corrected! useful if q is not explicitely necessary" ].
"r rows allButFirst withIndexDo: [:aRow :ri|1 to: (ri min: self numberOfColumns ) do: [:ci|aRow at: ci put:0  ]   ]  ""not necessary with equalsTo:0"  
	i :=0.
	[(r rowAt: colSize) allSatisfy: [:n| n=0]  ]whileTrue: [i :=i+1.colSize :=colSize -1].
	i>0 ifTrue: [ r :=DhbMatrix rows: (r rows copyFrom: 1 to:  colSize). 
					i := q numberOfColumns - i. 
					q := DhbMatrix rows:  ( q rows collect: [:row| row copyFrom: 1 to: i]) ].  
	^{q. r}
]

{ #category : #dbh }
PMDhbMatrix >> qrFactorizationWithPivoting [
	| identMat q r hh colSize i lengthArray rank mx pivot |
	self numberOfRows < self numberOfColumns
		ifTrue: [ self error: 'numberOfRows<numberOfColumns' ].
	lengthArray := self columnsCollect: [ :col | col * col ].
	mx := lengthArray indexOf: lengthArray max.
	pivot := Array new: lengthArray size.
	rank := 0.
	r := DhbMatrix rows: rows deepCopy.
	colSize := self numberOfRows.
	q := DhbSymmetricMatrix identity: colSize.
	identMat := q deepCopy.
	[ 
	rank := rank + 1.
	pivot at: rank put: mx.
	r swapColumn: rank withColumn: mx.
	lengthArray swap: rank with: mx.
	hh := ((r columnAt: rank) copyFrom: rank to: colSize) householder.
	i := (DhbVector new: rank - 1 withAll: 0) , (hh at: 2).
	q := q * (identMat - ((hh at: 1) * i tensorProduct: i)).
	i := DhbMatrix rows: ((r rows allButFirst: rank - 1) collect: [ :aRow | aRow allButFirst: rank - 1 ]).
	i := i - ((hh at: 2) tensorProduct: (hh at: 1) * (hh at: 2) * i).
	i rows
		withIndexDo: [ :aRow :index | 
			aRow
				withIndexDo: [ :n :c | 
					r
						rowAt: rank + index - 1
						columnAt: rank + c - 1
						put:
							((n equalsTo: 0)
								ifTrue: [ 0 ]
								ifFalse: [ n ]) ] ].
	rank + 1 to: lengthArray size do: [ :ind | lengthArray at: ind put: (lengthArray at: ind) - (r rowAt: rank columnAt: ind) squared ].
	rank < lengthArray size
		ifTrue: [ 
			mx := (lengthArray copyFrom: rank + 1 to: lengthArray size) max.
			(mx equalsTo: 0)
				ifTrue: [ mx := 0 ].
			mx := mx > 0
				ifTrue: [ lengthArray indexOf: mx startingAt: rank + 1 ]
				ifFalse: [ 0 ] ]
		ifFalse: [ mx := 0 ].
	mx > 0 ] whileTrue.
	i := 0.
	[ (r rowAt: colSize) allSatisfy: [ :n | n = 0 ] ]
		whileTrue: [ 
			i := i + 1.
			colSize := colSize - 1 ].
	i > 0
		ifTrue: [ 
			r := DhbMatrix rows: (r rows copyFrom: 1 to: colSize).
			i := q numberOfColumns - i.
			pivot := pivot copyFrom: 1 to: i.
			q := DhbMatrix rows: (q rows collect: [ :row | row copyFrom: 1 to: i ]) ].
	^ {q.
	r.
	pivot}
]

{ #category : #dbh }
PMDhbMatrix >> rank [ 
	^	((self numberOfRows < self numberOfColumns 
			ifTrue: [ self transpose ] 
			ifFalse: [ self ])  qrFactorizationWithPivoting at: 2) rows size 
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

{ #category : #dbh }
PMDhbMatrix >> swapColumn: anIndex withColumn:   a2Index [
	self rowsDo: [ :r| r swap: anIndex with: a2Index ]  

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
