Class {
	#name : #VMQueueTest,
	#superclass : #VMTests,
	#category : #'PolySLAM-Tests'
}

{ #category : #tests }
VMQueueTest >> testPop [
	| queue |
	queue := VMQueue new.
	1 to: 7 do: [ :item |
		queue push: item. ].
	5 timesRepeat: [ Transcript show: queue pop printString; cr. ].
	8 to: 29 do: [ :item |
		queue push: item. ].
	
	self assert: queue pop equals: 6.
]

{ #category : #tests }
VMQueueTest >> testPush [
	| queue |
	queue := VMQueue new.
	1 to: 22 do: [ :item |
		queue push: item. ].
]
