"
This class is a container for two OrderedCollection instances named 'left' and 'right'. It is mainly used to keep track of points/vectors that are either on the left or right side of a hyperplane.
"
Class {
	#name : #VMLRCollection,
	#superclass : #Object,
	#type : #variable,
	#instVars : [
		'left',
		'right'
	],
	#category : #'PolySLAM-Core-Collections'
}

{ #category : #copying }
VMLRCollection >> copy [
	"creates a shallow copy, but left/right are new OrderedCollection instances,
	so that adding a new element to the copy does not modify the original."
	| newCollection |
	
	newCollection := self species new.
	newCollection left addAll: left.
	newCollection right addAll: right.
	
	^ newCollection
]

{ #category : #'GT Inspector' }
VMLRCollection >> gtInspectorRenderedIn: composite [
	<gtInspectorPresentationOrder: 50>
	
	(composite morph)
		title: 'Viewer';
		morph: [
			| renderObjects |
			renderObjects := VMRenderCollection new.
			self left do: [ :v |
				renderObjects add: (v asRenderableElement color: (Color fromString: '#FFB700'); lineWidth: 0.02). ].
			self right do: [ :v |
				renderObjects add: (v asRenderableElement color: (Color fromString: '#9BFF00'); lineWidth: 0.02). ].
			
			(VMViewer openWindowlessOn: renderObjects)
				autozoom.
		].
		
]

{ #category : #initialization }
VMLRCollection >> initialize [
	left := OrderedCollection new.
	right := OrderedCollection new.
]

{ #category : #accessing }
VMLRCollection >> left [
	^left
]

{ #category : #accessing }
VMLRCollection >> right [
	^right
]
