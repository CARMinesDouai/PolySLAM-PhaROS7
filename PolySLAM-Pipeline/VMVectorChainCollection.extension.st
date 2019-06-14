Extension { #name : #VMVectorChainCollection }

{ #category : #'*PolySLAM-Pipeline-Algo' }
VMVectorChainCollection >> asDoublyConnectedEdgeList [
	|list link|
	list := DoublyConnectedEdgeList new.
	self do:[: line|
		link := line asPSLinkedEdge.
		list add: link.
		link chain: list.
	].
	^ list
	
]
