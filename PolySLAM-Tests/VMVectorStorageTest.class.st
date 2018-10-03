Class {
	#name : #VMVectorStorageTest,
	#superclass : #VMTests,
	#category : #'PolySLAM-Tests'
}

{ #category : #tests }
VMVectorStorageTest >> testAdd [
	| polygonA polygonB storage allVectors |
	polygonA := VMPolygon fromPoints: {0@2.  2@2.  2@4.  0@4} withTypes: { 1. 1. 1. 1 }.
	polygonB := VMPolygon fromPoints: {0@0.  2@0.  2@2.  0@2} withTypes: { 1. 1. 1. 1 }.	
	
	storage := VMVectorStorage new.
	polygonA do: [ :vec | storage add: vec ].
	polygonB do: [ :vec | storage add: vec ].
	
	allVectors := storage asOrderedCollection.
	self assert: allVectors size equals: 8.
	
	"adding the same vectors multiple times should not increase the size"
	polygonA do: [ :vec | storage add: vec ].
	allVectors := storage asOrderedCollection.
	self assert: allVectors size equals: 8.

]

{ #category : #tests }
VMVectorStorageTest >> testAddAll [
	| polygonA polygonB storage allVectors |
	polygonA := VMPolygon fromPoints: {0@2.  2@2.  2@4.  0@4} withTypes: { 1. 1. 1. 1 }.
	polygonB := VMPolygon fromPoints: {0@0.  2@0.  2@2.  0@2} withTypes: { 1. 1. 1. 1 }.	
	
	storage := VMVectorStorage new.
	storage addAll: polygonA.
	storage addAll: polygonB.
	
	allVectors := storage asOrderedCollection.
	self assert: allVectors size equals: 8.

]

{ #category : #tests }
VMVectorStorageTest >> testCollect [
	| polygonA polygonB storage allVectors result |
	polygonA := VMPolygon fromPoints: {0@2.  2@2.  2@4.  0@4} withTypes: { 1. 1. 1. 1 }.
	polygonB := VMPolygon fromPoints: {0@0.  2@0.  2@2.  0@2} withTypes: { 1. 1. 1. 1 }.	
	
	storage := VMVectorStorage new.
	storage addAll: polygonA.
	storage addAll: polygonB.
	
	result := storage collect: [:v|v].
	
	allVectors := storage asOrderedCollection.
	self assert: allVectors size equals: result size.

]

{ #category : #tests }
VMVectorStorageTest >> testFindSimilarVectors [
	| polygonA polygonB storage result |
	polygonA := VMPolygon fromPoints: {0@2.  2@2.  2@4.  0@4} withTypes: { 1. 1. 1. 1 }.
	polygonB := VMPolygon fromPoints: {0@0.  2@0.  2@2.  0@2} withTypes: { 2. 2. 2. 2 }.	
	
	storage := VMVectorStorage new.
	storage addAll: polygonA.
	storage addAll: polygonB.
	
	result := storage findSimilarVectors: polygonA first.
	
	self assert: result size equals: 2.
	self assert: (result includes: polygonA first).
	self assert: (result includes: polygonB third).

]

{ #category : #tests }
VMVectorStorageTest >> testRemove [
	| polygonA polygonB storage allVectors |
	polygonA := VMPolygon fromPoints: {0@2.  2@2.  2@4.  0@4} withTypes: { 1. 1. 1. 1 }.
	polygonB := VMPolygon fromPoints: {0@0.  2@0.  2@2.  0@2} withTypes: { 1. 1. 1. 1 }.	
	
	storage := VMVectorStorage new.
	storage addAll: polygonA.
	storage addAll: polygonB.
	
	storage remove: polygonA first.
	storage remove: polygonB third.
	
	allVectors := storage asOrderedCollection.
	self assert: allVectors size equals: 6.

]

{ #category : #tests }
VMVectorStorageTest >> testVectorHash [
	| pointA pointB storage |
	pointA := 2.2@3.3.
	pointB := 6.0@1.1.
	storage := VMVectorStorage new.
	
	self
		assert: (storage vectorHash: (VMLineSegment from: pointA to: pointB type: 1))
		equals: (storage vectorHash: (VMLineSegment from: pointA to: pointB type: 2)).
	
	self
		assert: (storage vectorHash: (VMLineSegment from: pointA to: pointB type: 1))
		equals: (storage vectorHash: (VMLineSegment from: pointB to: pointA type: 2)).
	
	self
		assert: (storage vectorHash: (VMLineSegment from: pointA to: pointB type: 1))
		equals: (storage vectorHash: (VMLineSegment from: pointB to: pointA type: 1)).

]
