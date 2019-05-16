Class {
	#name : #PSProbabilistPolygonIntersectionHelper,
	#superclass : #PSPolygonIntersectionHelper,
	#instVars : [
		'matrix'
	],
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #intersection }
PSProbabilistPolygonIntersectionHelper >> calculateIntersectionOn: L 	except: blackList do: aBlock [
	|lastline vertex|
	L isEmpty ifTrue: [ ^self ].
	lastline := nil.
	L do: [:e|
		lastline
			ifNotNil: [
				lastline chain = e chain ifFalse:[
				(blackList includes:{lastline. e}) ifFalse:[
					"check for colinearity"
					(matrix at: lastline id at: e id) = 0 ifTrue:[
						vertex := PSVertex intersectionOf: lastline  and: e.
						blackList add: {lastline.e};add: {e. lastline}.
						vertex ifNotNil: [
							lastline addIntersectionPoint: vertex.
							e addIntersectionPoint: vertex.
							aBlock value: vertex ].
					]
				]
			]].
		lastline := e
	]

	
]

{ #category : #public }
PSProbabilistPolygonIntersectionHelper >> calculateProbability [
	|collection idx|
	idx := 1.
	collection := OrderedCollection new.
	polygonA linksDo:[:e| e id:idx. collection add:e.  idx := idx +1].
	polygonB linksDo:[:e| e id:idx. collection add:e.  idx := idx +1].
	matrix := PSAdjacencyMatrix fromLines: collection probabilityHelper: PSMaxJoinProbability.
	"matrix vanishingTh: 0.1."
	"self halt."
	"matrix inspect."
	matrix := matrix trinaryAdjacencyMatrix makeSymetric.
]

{ #category : #public }
PSProbabilistPolygonIntersectionHelper >> perform [
	self calculateProbability.
	super perform
]
