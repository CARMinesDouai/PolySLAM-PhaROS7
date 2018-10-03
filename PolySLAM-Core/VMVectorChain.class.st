"
This class just provides sematic information and is otherwise simply an OrderedCollection.

A vector chain is a collection of vectors where each vector is connected to its precessor and successor in the collection by their start/end points. Unlike a polygon, the first and last vectors don't have to be connected too.
"
Class {
	#name : #VMVectorChain,
	#superclass : #OrderedCollection,
	#category : #'PolySLAM-Core-temp'
}

{ #category : #'instance creation' }
VMVectorChain class >> fromPoints: pointCollection withTypes: typeCollection [
	^ (self new)
		fromPoints: pointCollection withTypes: typeCollection
]

{ #category : #converting }
VMVectorChain >> asRenderableElement [
	^ VMLineSegCollectionRenderer model: self
]

{ #category : #printing }
VMVectorChain >> fromPoints: pointCollection withTypes: typeCollection [

	pointCollection size-1 <= typeCollection size ifFalse: [ ^self error: 'typeCollection is too small' ].
	
	1 to: pointCollection size -1 do: [ :index |
		self add:
			(VMLineSegment
				from: (pointCollection at: index)
				to: (pointCollection at: index+1)
				type: (typeCollection at: index)).
	].
]

{ #category : #'GT Inspector' }
VMVectorChain >> gtInspectorRenderedIn: composite [
	<gtInspectorPresentationOrder: 50>
	
	(composite morph)
		title: 'Viewer';
		morph: [
			(VMViewer openWindowlessOn: { self asRenderableElement })
				autozoom.
		].
]

{ #category : #printing }
VMVectorChain >> printString [
	| string |
	string := self species printString, ' fromPoints: {'.
	
	self do: [ :vec |
		string := string, ' ', vec pointA printString, '.'.
	].
	string := string, self last pointB printString.
	
	string := string, '} withTypes: {'.
	self do: [ :vec |
		string := string, ' ', vec type asInteger printString, '.'.
	].
	string := string, '}'.
	
	^ string
]
