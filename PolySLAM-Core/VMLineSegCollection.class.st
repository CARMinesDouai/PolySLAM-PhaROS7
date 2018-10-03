Class {
	#name : #VMLineSegCollection,
	#superclass : #OrderedCollection,
	#category : #'PolySLAM-Core-Data Structures: Points & Lines'
}

{ #category : #'as yet unclassified' }
VMLineSegCollection class >> fromPoints: aCollectionOfPoints [
	
	^(self new)
		fromPoints: aCollectionOfPoints;
		yourself.

]

{ #category : #'as yet unclassified' }
VMLineSegCollection class >> rendererClass [
	^VMLineSegCollectionRenderer
]

{ #category : #converting }
VMLineSegCollection >> asRenderableElement [
	^ self class rendererClass new model: self
]

{ #category : #accessing }
VMLineSegCollection >> bounds [
	"returns a zero-sized rect at 0@0 if empty. otherwise the boudary over all elements is returned."
	| rect |
	
	self ifEmpty: [ ^VMRectangle point: 0@0 point: 0@0 ].
	
	rect := self first bounds.
	self allButFirstDo: [ :element |
		rect := rect merge: element bounds.
	].
	
	^rect

]

{ #category : #construction }
VMLineSegCollection >> fromPoints: aCollectionOfPoints [
	
	self removeAll.
	
	aCollectionOfPoints doWithIndex: [ :aPoint :index |
		self add: (VMLineSegment from: aPoint to: (aCollectionOfPoints atWrap: index+1)).
	].
]

{ #category : #'GT Inspector' }
VMLineSegCollection >> gtInspectorRenderedIn: composite [
	<gtInspectorPresentationOrder: 50>
	composite inspectOnce.
	(composite morph)
		title: 'Viewer';
		morph: [
			(VMViewer openWindowlessOn: { self asRenderableElement })
				autozoom.
		].
		
]
