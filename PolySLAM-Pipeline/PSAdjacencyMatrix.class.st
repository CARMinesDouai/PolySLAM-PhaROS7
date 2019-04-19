Class {
	#name : #PSAdjacencyMatrix,
	#superclass : #PMSymmetricMatrix,
	#instVars : [
		'mean',
		'variance',
		'entropy',
		'th',
		'vanishingTh'
	],
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #'instance creation' }
PSAdjacencyMatrix class >> fromLines: aCollections [
	| matrix len i j p|
	len := aCollections size.
	matrix := self zerosRows: len cols: len.
	"fill with probability"
	i := 1.
	aCollections do:[:lineA|
		j := 1.
		j to: len do:[:k|
			p := (PSLinkingProbability from: lineA and: (aCollections at:k) ) probability.
					"max: (PSLinkingProbability from: (aCollections at:k) and: lineA ) probability."
			matrix at: i at: k put: p.
			"((p < 1) & (p > 0)) ifTrue:[
					p := p max: (PSLinkingProbability from: (aCollections at:k) and: lineA ) probability.
					matrix at: i at: k put: p.
					matrix at: k at: i put: p.			
			] ifFalse:[
				matrix at: i at: k put: p.
				matrix at: k at: i put: (PSLinkingProbability from: (aCollections at:k) and: lineA ) probability.
			]"
		].
		i := i+1.
	].
	^ matrix mvet
	
]

{ #category : #calculating }
PSAdjacencyMatrix >> binaryAdjacencyMatrix [
	|brows|
	brows := OrderedCollection new.
	self rowsDo: [ :r|
		brows add:(
			r collect:[:e| e >= th ifTrue:[ 1 ] ifFalse:[0] ]) ].
	^self class rows: brows.
]

{ #category : #accessing }
PSAdjacencyMatrix >> entropy [
	^entropy
]

{ #category : #initialization }
PSAdjacencyMatrix >> initialize [
	super initialize.
	vanishingTh := 0.25
]

{ #category : #laplace }
PSAdjacencyMatrix >> laplaceMatrix [
	^ self laplaceMatrixWithDiagonalVector: (self sum)
]

{ #category : #laplace }
PSAdjacencyMatrix >> laplaceMatrixWithDiagonalVector:vector [
	|matrix lrows row|
	
	lrows := OrderedCollection new.
	1 to: vector size do:[:i|
		row := PMVector zeros: vector size.
		row at:i put: (vector at:i).
		lrows add: row.
	].
	matrix := self class rows: lrows.
	matrix := matrix - self.
	^ matrix
]

{ #category : #accessing }
PSAdjacencyMatrix >> mean [
	^mean
]

{ #category : #calculating }
PSAdjacencyMatrix >> mvet [
	|values size|
	"mean variance entroy and automatic threshold"
	values := self nonVaninshingElements.
	size := values size.
	mean :=  (values sum) /  size.
	variance := (values collect:[:e| (mean - e) squared]) sum / size.
	entropy := (0 - ((values collect:[:e| e*(e log:2) ]) sum)) / size.
	th := mean - (variance) + entropy.
	"th := 0.55."
	^ self 
]

{ #category : #accessing }
PSAdjacencyMatrix >> nonVaninshingElements [
	|collection |
	collection := OrderedCollection new.
	self rowsDo: [ :r|
		r do:[:e| e > vanishingTh ifTrue:[collection add:e]]].
	^ collection asPMVector 
]

{ #category : #accessing }
PSAdjacencyMatrix >> th [
	^ th
]

{ #category : #calculating }
PSAdjacencyMatrix >> trinaryAdjacencyMatrix [
	|brows|
	brows := OrderedCollection new.
	self rowsDo: [ :r|
		brows add:(
			r collect:[:e| 
				((e = 0) | (e = 1))
					ifTrue:[e]
					ifFalse:[
						e > th ifTrue: [  -1 ] ifFalse:[0]
					]
			])].
	^self class rows: brows.
]

{ #category : #accessing }
PSAdjacencyMatrix >> variance [
	^ variance
]
