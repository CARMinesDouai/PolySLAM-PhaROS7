Class {
	#name : #PSFFINNCollection,
	#superclass : #Object,
	#instVars : [
		'collection',
		'tree'
	],
	#category : #'PolySLAM-Pipeline-Helper'
}

{ #category : #accessing }
PSFFINNCollection >> add: aVector [
	collection add:aVector.
	self lib kdInsertLine: aVector to:tree  resolution: 0.05 index: collection size
	
]

{ #category : #accessing }
PSFFINNCollection >> addAll: aCollection [
	aCollection do: [ :obj |
		self add: obj.
	].
]

{ #category : #accessing }
PSFFINNCollection >> addedVectors [
	^collection 
]

{ #category : #converting }
PSFFINNCollection >> asNNCollection [
	^self
]

{ #category : #nodes }
PSFFINNCollection >> cleanup [
	tree ifNil: [ ^self ].
	self lib kdFree: tree
]

{ #category : #'find nearest neighbor' }
PSFFINNCollection >> findNearest:aPoint [
	|id v cPoint|
	id := self lib kdNearestLineFrom: tree x: aPoint x y: aPoint y. 
	((id = 0)| (id > collection size)) ifTrue:[ ^nil ].
	v := collection at: id.
	cPoint := v closestPoint: aPoint.
	"Transcript show: id asString;cr."
	^VMNNSearchResult object: cPoint  squareDist:(cPoint squaredDistanceTo: aPoint) 
]

{ #category : #'find nearest neighbor' }
PSFFINNCollection >> findNearest:aPoint sensorPoint: sensorPoint [
	^ self findNearest: aPoint
]

{ #category : #initialization }
PSFFINNCollection >> initialize [
	collection := OrderedCollection new.
	tree := self lib kdCreate: 2
]

{ #category : #library }
PSFFINNCollection >> lib [
	^ LibPolySLAMFFI singleton 
]
