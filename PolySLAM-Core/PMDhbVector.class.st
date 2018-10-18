Class {
	#name : #PMDhbVector,
	#superclass : #Array,
	#type : #variable,
	#category : #'PolySLAM-Core-LinAlgebra'
}

{ #category : #operation }
PMDhbVector >> * aNumberOrMatrixOrVector [
		"Answers the product of the receiver with the argument. The argument can be a number, matrix or vector. "
	^ aNumberOrMatrixOrVector productWithVector: self
]

{ #category : #operation }
PMDhbVector >> + aVector [
	"Answers the sum of the receiver with aVector."
	| answer n |
	answer := self class new: self size.
	n := 0.
	self with: aVector do:
		[ :a :b | 
		  n := n + 1. 
		  answer at: n put: ( a + b).
		].
	^answer
]

{ #category : #operation }
PMDhbVector >> - aVector [
	"Answers the difference of the receiver with aVector."
	| answer n |
	answer := self class new: self size.
	n := 0.
	self with: aVector do:
		[ :a :b | 
		  n := n + 1. 
		  answer at: n put: ( a - b).
		].
	^answer
]

{ #category : #transformation }
PMDhbVector >> accumulate: aVectorOrAnArray [
	"Modify the receiver adding the contents of the argument to the receiver."
	1 to: self size do: [ :n | self at: n put: ((self at: n) + (aVectorOrAnArray at: n))].
]

{ #category : #transformation }
PMDhbVector >> accumulateNegated: aVectorOrAnArray [
	"Modify the receiver adding the negated contents of the argument to the receiver."
	1 to: self size do: [ :n | self at: n put: ((self at: n) - (aVectorOrAnArray at: n))].
]

{ #category : #complex }
PMDhbVector >> adaptToComplex: rcvr andSend: selector [
	^ self collect: [:ea | rcvr perform: selector  with: ea].
]

{ #category : #quad }
PMDhbVector >> adaptToQuaternion: aQuaternion andSend: aByteSymbol [ 
	^ self collect: [:ea | aQuaternion perform: aByteSymbol  with: ea].
]

{ #category : #'as yet unclassified' }
PMDhbVector >> asArray [
	
	| array i|
	array := Array new: self size.
	i := 0.
	self do: [:item | array basicAt: (i:=i+1) put: item].
	^ array
]

{ #category : #creation }
PMDhbVector >> asDhbVector [
	"Answer self since the receiver is a vector."
	^ self
]

{ #category : #'as yet unclassified' }
PMDhbVector >> asPoint [
	^Point x: (self at: 1) y: (self at: 2).
]

{ #category : #dhb }
PMDhbVector >> householder [
	"returns a collection of the skalar beta and the housholder vector"
	|s v b u x |
	s :=self allButFirst.
	s := s *s.
	v := self copy.
	v at: 1 put: 1.  
	s = 0 
		ifTrue: [ b :=0 ] 
		ifFalse: [
			u :=((x:=self at:1)squared + s)sqrt .
			v 
				at: 1 
				put: ((x <=0) ifTrue: [x -u] ifFalse:  [0 - s / (x + u)]).
			b :=(v at: 1) squared * 2 / (s + (v at: 1) squared).
			v := v / (v at: 1) ].
	^{b. v}
]

{ #category : #transformation }
PMDhbVector >> negate [
	"Inverse the sign of all components of the receiver."
	1 to: self size do: [ :n | self at: n put: (self at: n) negated].
]

{ #category : #operation }
PMDhbVector >> negated [
	^ self * -1
]

{ #category : #operation }
PMDhbVector >> norm [
	"Answer the norm of the receiver."
	^(self * self) sqrt
]

{ #category : #creation }
PMDhbVector >> normalized [
	^ (1 / self norm) * self
]

{ #category : #operation }
PMDhbVector >> productWithMatrix: aMatrix [
	"Answers the product of aMatrix with the receiver."
	^aMatrix rowsCollect: [ :each | each * self]
]

{ #category : #operation }
PMDhbVector >> productWithVector: aVector [
	"Answers the scalar product of aVector with the receiver."
	| n |
	n := 0.
	^self inject: 0
			into: [ :sum :each | n := n + 1. (aVector at: n) * each + sum]
]

{ #category : #operation }
PMDhbVector >> scalarProduct: aVector [
	
	| product n |
	n := 0.
	product := self collect: [ :each | n := n + 1. (aVector at: n) * each].
	n := product size.
	[ n > 1]
		whileTrue:[ | i j|
					i := 1.
					j := n.
					[ i < j]
						whileTrue: [ product at: i put: ( product at: i) + ( product at: j).
									 j := j - 1.
									 i := i + 1.
								   ].
					n := i min: j.
				  ].
	^product at: 1
]

{ #category : #transformation }
PMDhbVector >> scaleBy: aNumber [
	"Modify the receiver elements by a multiplicating factor."
	1 to: self size do: [ :n | self at: n put: ((self at: n) * aNumber)].
]

{ #category : #operation }
PMDhbVector >> tensorProduct: aVector [
	"Answers the tensor product of the receiver with aVector."
	^self == aVector "dont use #="
			ifTrue: [DhbSymmetricMatrix new: self size function:[:x :y|x*y]] 
			ifFalse:[DhbMatrix rows: ( self collect: [ :a | aVector collect: [ :b | a * b]])]

]
