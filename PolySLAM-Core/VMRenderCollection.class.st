"
Same as an OrderedCollection, but adds support for rendering via #asRenderableElement, #bounds, and #gtInspectorRenderedIn: methods.

note, that only content that actually supports rendering can be rendered this way.
"
Class {
	#name : #VMRenderCollection,
	#superclass : #OrderedCollection,
	#category : #'PolySLAM-Core-Collections'
}

{ #category : #'as yet unclassified' }
VMRenderCollection >> asRenderableElement [
	^ VMCollectionRenderer new model: self
]

{ #category : #accessing }
VMRenderCollection >> bounds [
	| rect index |
	rect := nil.
	index := 1.
	
	"find an element that returns a non-nil bounds"
	(rect isNil and: [index <= self size]) whileTrue: [
		rect := self at: index bounds.
		index := index + 1.]. 
	
	"merge with any non-nil bounds that remain"
	index to: self size do: [ :i |
		(self at: i) bounds ifNotNil: [ :tempRect | rect := rect merge: tempRect ] ].
	
	^ rect
]

{ #category : #'as yet unclassified' }
VMRenderCollection >> gtInspectorRenderedIn: composite [
	<gtInspectorPresentationOrder: 50>
	
	(composite morph)
		title: 'Viewer';
		morph: [
			(VMViewer openWindowlessOn: { self asRenderableElement })
				autozoom.
		].
]
