Class {
	#name : #DhbLUPDecomposition,
	#superclass : #Object,
	#instVars : [
		'rows',
		'permutation',
		'parity'
	],
	#category : #'PolySLAM-Core-LinAlgebra'
}

{ #category : #creation }
DhbLUPDecomposition class >> direct: anArrayOfArrays [
	
	^ self basicNew initialize: anArrayOfArrays.
]

{ #category : #creation }
DhbLUPDecomposition class >> equations: anArrayOfArrays [
		"(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 30/3/99 "
		^self new initialize: ( anArrayOfArrays collect: [ :each | each copy]).
]

{ #category : #private }
DhbLUPDecomposition >> backwardSubstitution: anArray [
	"Private"
	| n sum answer |
	n := rows size.
	answer := DhbVector new: n.
	n to: 1 by: -1 do:
		[ :i |
		  sum := anArray at: i.
		  ( i + 1) to: n do: [ :j | sum := sum - ( ( ( rows at: i) at: j) * ( answer at: j))].
		  answer at: i put: sum / ( ( rows at: i) at: i).
		].
	^answer
]

{ #category : #private }
DhbLUPDecomposition >> decompose [
	"Private"
	| n |
	n := rows size.
	permutation := (1 to: n) asArray.
	1 to: ( n - 1) do:
		[ :k |
		  self swapRow: k withRow: ( self largestPivotFrom: k);
			   pivotAt: k.
		].
]

{ #category : #operations }
DhbLUPDecomposition >> determinant [
	| n |
	permutation isNil
		ifTrue: [ self protectedDecomposition ].
	permutation = 0
		ifTrue: [ ^ 0 ].	"Singular matrix has 0 determinant"
	n := 0.
	^ rows inject: parity
		  into: [ :det :each | n := n + 1. ( each at: n) * det ]
]

{ #category : #private }
DhbLUPDecomposition >> forwardSubstitution: anArray [
	"Private"
	| n sum answer|
	answer := permutation collect: [ :each | anArray at: each].
	n := rows size.
	2 to: n do:
		[ :i |
		  sum := answer at: i.
		  1 to: (i - 1) do: [ :j | sum := sum - (((rows at: i) at: j) * (answer at: j))].
		  answer at: i put: sum.
		].
	^answer
]

{ #category : #initialization }
DhbLUPDecomposition >> initialize: anArrayOfArrays [
	rows := anArrayOfArrays.
	parity := 1.
	^ self
]

{ #category : #operations }
DhbLUPDecomposition >> inverseMatrixComponents [
	| n inverseRows column |
	permutation isNil
		ifTrue: [ self protectedDecomposition].
	permutation = 0
		ifTrue: [ ^ nil].	"Singular matrix has no inverse"
	n := rows size.
	inverseRows := (1 to: n) asDhbVector collect: [ :j | DhbVector new: n].
	1 to: n do:
		[ :j |
		  column := self solve: ( ( Array new: rows size) atAllPut: 0; at: j put: 1; yourself).
		  column ifNil: [^nil].	"Singular matrix has no inverse"
		  1 to: n do: [ :i | ( inverseRows at: i) at: j put: ( column at: i)].
		]. 
	^inverseRows
]

{ #category : #operations }
DhbLUPDecomposition >> largestPivotFrom: anInteger [
	"Private - Answers the largest pivot element in column anInteger, from position anInteger upward."
	| valueOfMaximum indexOfMaximum value |
	valueOfMaximum := ((rows at: anInteger) at: anInteger) abs.
	indexOfMaximum := anInteger.
	(anInteger + 1) to: rows size do:
		[ :n |
		  value := ((rows at: n) at: anInteger) abs.
		  value > valueOfMaximum
				ifTrue: [ valueOfMaximum := value.
						  indexOfMaximum := n ].
		].
	^ indexOfMaximum
]

{ #category : #private }
DhbLUPDecomposition >> pivotAt: anInteger [
	"Private"
	| inversePivot size k |
	inversePivot := 1 / ((rows at: anInteger) at: anInteger).
	size := rows size.
	k := anInteger + 1.
	k to: size
		do: [ :i |
			  (rows at: i) at: anInteger put: ((rows at: i) at: anInteger) * inversePivot.
			  k to: size
				do: [ :j |
					  (rows at: i) at: j put: ((rows at: i) at: j) - (((rows at: i) at: anInteger) * ((rows at: anInteger) at: j)).
					]
			].
]

{ #category : #printing }
DhbLUPDecomposition >> printOn: aStream [
	
	| delimitingString |
	rows do:
		[ :row |
		  delimitingString := '('.
		  row do:
			[ :each |
				aStream nextPutAll: delimitingString.
				each printOn: aStream.
				delimitingString := ' ' ].
		  aStream nextPut: $).
		]
		separatedBy: [ aStream cr ]
]

{ #category : #private }
DhbLUPDecomposition >> protectedDecomposition [
	"Private - If decomposition fails, set permutation to 0."
	[ self decompose] on: Error do: [ :signal | permutation := 0. signal return: nil].
]

{ #category : #private }
DhbLUPDecomposition >> solve: anArrayOrVector [
	permutation isNil
		ifTrue: [ self protectedDecomposition ].
	^ permutation = 0
		ifTrue: [ nil ]
		ifFalse:[ 
			[self backwardSubstitution: ( self forwardSubstitution: anArrayOrVector)] on: ZeroDivide do: [:e|  nil] ]
]

{ #category : #private }
DhbLUPDecomposition >> swapRow: anInteger1 withRow: anInteger2 [
	"Private - Swap the rows indexed by the given integers."
	| swappedRow |
	anInteger1 = anInteger2 ifTrue: [ ^ self ].
	swappedRow := rows at: anInteger1.
	rows at: anInteger1 put: (rows at: anInteger2).
	rows at: anInteger2 put: swappedRow.
	swappedRow := permutation at: anInteger1.
	permutation at: anInteger1 put: (permutation at: anInteger2).
	permutation at: anInteger2 put: swappedRow.
	parity := parity negated
]
