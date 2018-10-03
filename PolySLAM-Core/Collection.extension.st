Extension { #name : #Collection }

{ #category : #'*PolySLAM-Core' }
Collection >> asVMQuadTree [
	^VMQuadTreeNode fromCollection: self.
]

{ #category : #'*PolySLAM-Core' }
Collection >> asVMQuadTree2 [
	^VMQuadTreeNode2 fromCollection: self.
]

{ #category : #'*PolySLAM-Core' }
Collection >> bounds [
	| rect |
	self ifEmpty: [ ^nil ].
	
	rect := self anyOne bounds.
	
	self do: [ :obj |
		(obj respondsTo: #bounds) ifTrue:[ rect := rect merge: obj bounds.] ].
	
	^rect
]

{ #category : #'*PolySLAM-Core' }
Collection >> removeAll: aCollection ifAbsent: aBlock [
	"Remove each element of aCollection from the receiver. If successful for 
	each, answer aCollection. Otherwise create an error notification.
	ArrayedCollections cannot respond to this message."

	aCollection == self ifTrue: [^self removeAll].
	aCollection do: [:each | self remove: each ifAbsent: [aBlock cull: each]].
	^ aCollection
]
