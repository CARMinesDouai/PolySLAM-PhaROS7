"
not working as intended
"
Class {
	#name : #PMPolygonMerger,
	#superclass : #Object,
	#instVars : [
		'inputPolygons',
		'startPointDict',
		'resultCollection'
	],
	#category : #'PolySLAM-Extra-Experimental'
}

{ #category : #accessing }
PMPolygonMerger >> dict [
	^ startPointDict
]

{ #category : #'as yet unclassified' }
PMPolygonMerger >> initialize [
	super initialize.
	resultCollection := OrderedCollection new.
]

{ #category : #accessing }
PMPolygonMerger >> inputPolygons [
	^ inputPolygons
]

{ #category : #accessing }
PMPolygonMerger >> inputPolygons: collectionOfPolygons [
	inputPolygons := collectionOfPolygons asVMPolygonCollection.
	
	startPointDict := Dictionary new.
	inputPolygons do: [ :polygon |
		polygon do: [ :vector |
			startPointDict at: vector pointA
				ifPresent: [ (startPointDict at: vector pointA) add: vector ]
				ifAbsent: [ startPointDict at: vector pointA put: OrderedCollection new.
					(startPointDict at: vector pointA) add: vector]. ]. ].
]

{ #category : #'as yet unclassified' }
PMPolygonMerger >> merge [
	| newPolygon currentVector |
	newPolygon := VMPolygon new.
	currentVector := self topLeft.
	
	
]

{ #category : #'as yet unclassified' }
PMPolygonMerger >> nextVector: prevVector [
	| collection |
	collection := startPointDict at: prevVector pointB.

]

{ #category : #accessing }
PMPolygonMerger >> remainingVectors [
	| collection |
	
	collection := VMRenderCollection new.
	startPointDict do: [ :vectorCollection |
		collection addAll: vectorCollection ].
	
	^ collection
]

{ #category : #'as yet unclassified' }
PMPolygonMerger >> removePolygon: polygon [
	polygon do: [ :vector |
		| collection |
		collection := startPointDict at: vector pointA.
		collection remove: vector.
		collection ifEmpty: [ startPointDict removeKey: vector pointA ]. ].
]

{ #category : #'as yet unclassified' }
PMPolygonMerger >> result [
	^ resultCollection
]

{ #category : #'as yet unclassified' }
PMPolygonMerger >> selectNextVector: prevVector collection: collection [
	| angle bestAngle bestVector |
	
	bestAngle := prevVector deltaAngle: collection first.
	bestVector := collection first.
	
	collection allButFirstDo: [ :aVector |
		angle := prevVector deltaAngle: aVector.
		angle < bestAngle ifTrue: [ bestAngle := angle. bestVector := aVector ]. ].
	
	^ bestVector

]

{ #category : #accessing }
PMPolygonMerger >> topLeft [
	"find and return the vector whose pointA is the top-most (smallest y value). if mulitple qualify, we choose the one
	left-most (smallest x value)."
	| topLeftVector |
	
	(inputPolygons isNil or: inputPolygons isEmpty) ifTrue: [ ^ nil ].
	topLeftVector := inputPolygons first first.
	
	inputPolygons do: [ :polygon |
		polygon do: [ :vector |
			topLeftVector pointA y > vector pointA y
				ifTrue: [ topLeftVector := vector. ]
				ifFalse: [
					(topLeftVector pointA y = vector pointA y and: [topLeftVector pointA x > vector pointA]) ifTrue: [
						topLeftVector := vector.	]. ].	]. ].
	
	^ topLeftVector
]

{ #category : #accessing }
PMPolygonMerger >> topLeftOld [
	"find and return the vector whose pointA is the top-most (smallest y value). if mulitple qualify, we choose the one
	left-most (smallest x value)."
	| topLeftVector |
	
	(inputPolygons isNil or: inputPolygons isEmpty) ifTrue: [ ^ nil ].
	topLeftVector := inputPolygons first first.
	
	inputPolygons do: [ :polygon |
		polygon do: [ :vector |
			topLeftVector pointA y > vector pointA y
				ifTrue: [ topLeftVector := vector. ]
				ifFalse: [
					(topLeftVector pointA y = vector pointA y and: [topLeftVector pointA x > vector pointA]) ifTrue: [
						topLeftVector := vector.	]. ].	]. ].
	
	^ topLeftVector
]
