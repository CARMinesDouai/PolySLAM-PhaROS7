Extension { #name : #BTree }

{ #category : #'*PolySLAM-Pipeline-Algo' }
BTree >> asRenderableElement [
	^ self asOrderedCollection asRenderableElement 
]
