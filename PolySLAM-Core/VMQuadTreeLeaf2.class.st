Class {
	#name : #VMQuadTreeLeaf2,
	#superclass : #VMQuadTreeNode2,
	#instVars : [
		'data'
	],
	#category : #'PolySLAM-Core-Nearest Neighbor Search'
}

{ #category : #adding }
VMQuadTreeLeaf2 >> add: aPoint [
	"note: leafs never check if 'aPoint' is inside or not - we just assume that the
	point lies inside the area covered by this leaf."
	
	
	(data size >= self maxDataSize) ifTrue: [
		
		data do: [ :obj |
			"checking that the objects don't have the same coordinates, otherwise we will end up in an invinite recusive loop"
			((obj x ~= (aPoint x)) or: [obj y ~= (aPoint y)]) ifTrue: [
				| newNode |
				newNode := self class node rectangle: rectangle parent: parent.
				newNode addAll: data.
				newNode := newNode add: aPoint.
				^newNode.
			].
		].
	].
	
	data add: aPoint.
	^self.
	

]

{ #category : #accessing }
VMQuadTreeLeaf2 >> anyOne [
	data ifEmpty: [ ^nil. ].
	^data first.
]

{ #category : #enumerating }
VMQuadTreeLeaf2 >> do: aBlock [
	data do: [ :obj |
		aBlock value: obj.
	].
]

{ #category : #helper }
VMQuadTreeLeaf2 >> findNearest: pointLikeObject result: resultObj [
	
	((resultObj object isNil) and: [data isNotEmpty]) ifTrue: [
		resultObj
			object: data first;
			squareDist: ( pointLikeObject squaredDistanceTo: data first ).
	].
	
	data do: [ :obj |
		((pointLikeObject squaredDistanceTo: obj) < (resultObj squareDist)) ifTrue: [
			resultObj
				object: obj;
				squareDist: ( pointLikeObject squaredDistanceTo: obj ).
		].
	].
]

{ #category : #initialization }
VMQuadTreeLeaf2 >> initialize [
	"no 'super initialize', because we don't use any children in the leafs"
	
	children := nil.
	
	data := OrderedCollection new: self maxDataSize.
]

{ #category : #accessing }
VMQuadTreeLeaf2 >> size [
	^data size.
]
