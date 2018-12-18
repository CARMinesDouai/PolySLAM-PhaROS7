"
Same as an OrderedCollection, but supports the #bounds method, assuming that all entries in the collection support it as well.
"
Class {
	#name : #VMRenderCollection,
	#superclass : #OrderedCollection,
	#category : #'PolySLAM-Core-Collections'
}

{ #category : #accessing }
VMRenderCollection >> bounds [
	| rect index |
	rect := nil.
	index := 1.
	(rect isNil and: [index <= self size]) whileTrue: [
		rect := self at: index bounds.
		index := index + 1.]. 
	
	index to: self size do: [ :i |
		(self at: i) bounds ifNotNil: [ :tempRect | rect := rect merge: tempRect ] ].
	
	^ rect
]
