Extension { #name : #Number }

{ #category : #'*PolySLAM-Core' }
Number >> addPolynomial: aPolynomial [
		"(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 19/4/99 "
	^aPolynomial addNumber: self
]

{ #category : #'*PolySLAM-Core' }
Number >> asDhbVector [
	^{ self }
]

{ #category : #'*PolySLAM-Core' }
Number >> asPMVector [
	^{ self }
]

{ #category : #'*PolySLAM-Core' }
Number >> asTimeString [
	"interpretes self as seconds and prints a human-readable string"
	| days hours minutes seconds stringStream |
	seconds := self.
	days := seconds // (60*60*24).
	seconds := seconds - (days * (60*60*24)).
	hours := seconds // (60*60).
	seconds := seconds - (hours * (60*60)).
	minutes := seconds // 60.
	seconds := seconds - (minutes * 60).
	
	stringStream := String new writeStream.
	days > 0 ifTrue: [
		stringStream nextPutAll: days printString;
		nextPutAll: 'd '].
	(days > 0 or: [hours > 0]) ifTrue: [
		stringStream nextPutAll: hours printString;
		nextPutAll: 'h '].
	((days > 0 or: [hours > 0]) or: [minutes > 0]) ifTrue: [
		stringStream nextPutAll: minutes printString;
		nextPutAll: 'm '].
	stringStream nextPutAll: (seconds round: 2) printString;
		nextPutAll: 's'.
		
	^ stringStream contents
		
	
]

{ #category : #'*PolySLAM-Core' }
Number >> beta: aNumber [
		"Computes the beta function of the receiver and aNumber
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 1/3/99 "
	^( self logBeta: aNumber) exp
]

{ #category : #'*PolySLAM-Core' }
Number >> dividingPolynomial: aPolynomial [
		"(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 17/4/99 "
	^aPolynomial timesNumber: (1 / self)
]

{ #category : #'*PolySLAM-Core' }
Number >> equalsTo: aNumber [
		"compare to Float>>closeTo:
		
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 21/4/99 "
	^self relativelyEqualsTo: aNumber upTo: DhbFloatingPointMachine new defaultNumericalPrecision
]

{ #category : #'*PolySLAM-Core' }
Number >> errorFunction [
		"Answer the error function for the receiver.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 11/2/99 "
	^ DhbErfApproximation new value: self
]

{ #category : #'*PolySLAM-Core' }
Number >> forceBetween: lowerEnd and: upperEnd [
	"limits the number to lie in the range [lowerEnd, upperEnd]."
	self < lowerEnd ifTrue: [ ^lowerEnd ].
	self > upperEnd ifTrue: [ ^upperEnd ].
	^self
	
]

{ #category : #'*PolySLAM-Core' }
Number >> gamma [
		"Compute the Gamma function for the receiver.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 11/2/99 "
	^ self > 1
		ifTrue: [ ^ DhbLanczosFormula new gamma: self]
		ifFalse:[ self < 0
						ifTrue: [ Float pi / ( ( Float pi * self) sin * ( 1 - self) gamma)]
						ifFalse:[ ( DhbLanczosFormula new gamma: ( self + 1)) / self]
					]
]

{ #category : #'*PolySLAM-Core' }
Number >> logBeta: aNumber [
		"Computes the logarithm of the beta function of the receiver and aNumber
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 1/3/99 "
	^self logGamma + aNumber logGamma - ( self + aNumber) logGamma
]

{ #category : #'*PolySLAM-Core' }
Number >> logGamma [
		"Computes the log of the Gamma function (for positive numbers only)
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 1/3/99 "
	^self > 1
		ifTrue: [ DhbLanczosFormula new logGamma: self]
		ifFalse:[ self > 0
						ifTrue: [ ( DhbLanczosFormula new logGamma: ( self + 1) ) - self ln ]
						ifFalse: [ ^self error: 'Argument for the log gamma function must be positive']
					]
]

{ #category : #'*PolySLAM-Core' }
Number >> productWithMatrix: aMatrix [
^aMatrix class rows: (aMatrix rowsCollect: [:r| self productWithVector: r])
]

{ #category : #'*PolySLAM-Core' }
Number >> productWithVector: aVector [
		"Answers a new vector product of the receiver with aVector.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 11/2/99 "
	^aVector collect: [ :each | each * self]
]

{ #category : #'*PolySLAM-Core' }
Number >> random [
		"Answers a random number distributed between 0 and the receiver.
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 17/2/99 "
	^self class random * self
]

{ #category : #'*PolySLAM-Core' }
Number >> relativelyEqualsTo: aNumber upTo: aSmallNumber [
		"compare to Float>>closeTo:
		generally called from Number>>equalsTo:
		 (c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 21/4/99 "
	| norm |
	norm := self abs max: aNumber abs.
	^norm <= DhbFloatingPointMachine new defaultNumericalPrecision
		or: [ (self - aNumber) abs < ( aSmallNumber * norm)]
]

{ #category : #'*PolySLAM-Core' }
Number >> subtractToPolynomial: aPolynomial [
		"(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 19/4/99 "
	^aPolynomial addNumber: self negated
]

{ #category : #'*PolySLAM-Core' }
Number >> timesPolynomial: aPolynomial [
		"(c) Copyrights Didier BESSET, 1999, all rights reserved.
		 Initial code: 17/4/99 "
	^aPolynomial timesNumber: self
]
