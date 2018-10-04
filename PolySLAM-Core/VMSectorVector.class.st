Class {
	#name : #VMSectorVector,
	#superclass : #Object,
	#instVars : [
		'vector',
		'polygon',
		'hyperplane'
	],
	#category : #'PolySLAM-Core-Collections, Trees & Graphs'
}

{ #category : #constructing }
VMSectorVector class >> vector: aVector polygon: aPolygon hyperplane: aPlane [
	^ self new
		vector: aVector;
		polygon: aPolygon;
		hyperplane: aPlane;
		yourself
]

{ #category : #converting }
VMSectorVector >> asPolygon [
	^self polygon
]

{ #category : #accessing }
VMSectorVector >> hyperplane [
	^ hyperplane
]

{ #category : #accessing }
VMSectorVector >> hyperplane: aPlane [
	hyperplane := aPlane.
]

{ #category : #accessing }
VMSectorVector >> polygon [
	^ polygon
]

{ #category : #accessing }
VMSectorVector >> polygon: aPolygon [
	polygon := aPolygon.
]

{ #category : #accessing }
VMSectorVector >> vector [
	^ vector
]

{ #category : #accessing }
VMSectorVector >> vector: aVector [
	vector := aVector.
]
