"
A storage class that holds a sector/polygon, one sector-typed vector of that polygon, and the hyperplane to which the vector is collinear.
This class basically only exists to provide a name to this collection, instead of just returning an Array instance.

The #asPolygon method has been added to make it more convenient when passing around this class
"
Class {
	#name : #VMSectorVector,
	#superclass : #Object,
	#instVars : [
		'vector',
		'polygon',
		'hyperplane'
	],
	#category : #'PolySLAM-Core-Collections'
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
