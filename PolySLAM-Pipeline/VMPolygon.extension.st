Extension { #name : #VMPolygon }

{ #category : #'*PolySLAM-Pipeline-Algo' }
VMPolygon >> asDoublyConnectedEdgeList [
	^ self asDoublyConnectedEdgeListDo: nil
]

{ #category : #'*PolySLAM-Pipeline-Algo' }
VMPolygon >> asDoublyConnectedEdgeListDo: ablock [
	|list link|
	list := DoublyConnectedEdgeList new.
	self do:[: line|
		link := line asPSLinkedEdge.
		list add: link.
		link chain: list.
		ablock ifNotNil: [ ablock value: link]	
	].
	list close.
	^ list
	
]

{ #category : #'*PolySLAM-Pipeline-Algo' }
VMPolygon >> mergeWith: anotherPolygon [
	^ self asDoublyConnectedEdgeList mergeWith: anotherPolygon
]
