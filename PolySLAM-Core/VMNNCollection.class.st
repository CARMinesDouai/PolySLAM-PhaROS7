"
This is an abstract class / interface for collections that allow fast 'nearest neighbor' queries. This class only supports a subset of the normal collection interface to make it easier and quicker to write an implementation.


Public API and Key Messages

- add: <point-like object>
	similar to normal collections, but the object is expected to be derived from the Point class
	
- addAll: <collection of point-like objects>
	same as for normal collections. the provided collection only needs to support #do

- anyOne
	similar to normal collections, this returns an element that has been added beforehand. calling this method multiple times without adding or removing elements will always return the same element.
	
- do: <block>
	similar to normal collections. each element is passed only once, but there are no rules about the order they  are passed.
	
- findNearest: <point-like object>
	returns the object in the collection with the shortest distance to the provided object
	
- first
	returns an element from the collection. since elements are not ordered in a classical sense, this is equivalent to calling anyOne. it is provided to be more compatible with OrderedCollections, which makes it a bit easier to write debug/test/visualization code.
	
- size
	returns the number of objects that are stored in the collection


"
Class {
	#name : #VMNNCollection,
	#superclass : #Object,
	#category : #'PolySLAM-Core-Nearest Neighbor Search'
}

{ #category : #'rendering support' }
VMNNCollection class >> rendererClass [
	^VMNNCollectionRenderer
]

{ #category : #adding }
VMNNCollection >> add: pointLikeObject [
	^ self subclassResponsibility 
]

{ #category : #adding }
VMNNCollection >> addAll: collection [
	^ self subclassResponsibility 
]

{ #category : #accessing }
VMNNCollection >> anyOne [
	^ self subclassResponsibility 
]

{ #category : #converting }
VMNNCollection >> asNNCollection [
	^self
]

{ #category : #converting }
VMNNCollection >> asRenderableElement [
	^ self class rendererClass new model: self
]

{ #category : #enumerating }
VMNNCollection >> do: aBlock [
	^ self subclassResponsibility 
]

{ #category : #'find nearest neighbor' }
VMNNCollection >> findNearest: pointLikeObject [
	^self subclassResponsibility.
]

{ #category : #accessing }
VMNNCollection >> first [
	self subclassResponsibility.
]

{ #category : #testing }
VMNNCollection >> ifEmpty: aBlock [
	(self size < 1) ifTrue: [ aBlock value ].
]

{ #category : #accessing }
VMNNCollection >> root [
	"returns the root of the tree search structure. required for data structures that can create new root nodes when elements are added"
	^self subclassResponsibility.
]

{ #category : #accessing }
VMNNCollection >> size [
	self subclassResponsibility.
]
