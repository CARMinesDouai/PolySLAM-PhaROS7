Class {
	#name : #PSMapping,
	#superclass : #Object,
	#instVars : [
		'map',
		'update_per_n_kf',
		'interval',
		'onMapUpdate',
		'queue',
		'running'
	],
	#category : #'PolySLAM-Pipeline-Core'
}

{ #category : #accessing }
PSMapping >> addPolygon: p [
	<master>
	"self iostream ifNil: [ ^self ].
	self iostream isOpen ifFalse:[^self].
	self iostream  nextPut: p"
	"self processData: p"
	queue nextPut: p.
	interval := interval + 1.
	interval = 20 ifTrue:[
		TimeProfiler spyOn: [ self bench ]	
	]
]

{ #category : #benchmarking }
PSMapping >> bench [
	|d|
	[queue atEnd ] whileFalse: [ 
		d := queue next.
		[
			map := map insert: d.
		] 	on: Error do: [ Transcript show: 'Slave VM: Error on adding polygon'; cr.].
	]
]

{ #category : #initialization }
PSMapping >> initialize [
	super initialize.
	map := ((VMGridStorage gridSize: 2.0) cellClass: VMGridCellBSP; yourself)"VMBSPLeaf new".
	update_per_n_kf := 5. 
	interval := 0.
	onMapUpdate := nil.
	queue := SharedQueue new.
	running := false
]

{ #category : #accessing }
PSMapping >> map [
	^ map
]

{ #category : #accessing }
PSMapping >> onMapUpdate [
	^ onMapUpdate
]

{ #category : #accessing }
PSMapping >> onMapUpdate: anObject [
	onMapUpdate := anObject
]

{ #category : #process }
PSMapping >> process [
	[ running ] whileTrue: [ 
		queue atEnd ifFalse: [ self processData: queue next ]
	]
]

{ #category : #process }
PSMapping >> processData: d [
	|p|
	p := d.
	[
		VMBSPLeaf new insert: d.
		map := map insert: d.
	] on: Error do: [ Transcript show: 'Slave VM: Error on adding polygon'; cr. ^self ].
	"self iostream nextPut: map asCollectionOfSectors."
	interval = 0 ifTrue:["self iostream nextPut: map asCollectionOfSectors"
		onMapUpdate ifNotNil: [ onMapUpdate value: map asCollectionOfSectors ]	
	].
	interval := interval + 1.
	interval >= update_per_n_kf ifTrue:[ interval := 0 ].

]

{ #category : #process }
PSMapping >> rasterize [
	|sectors canvas|
	"draw everything on a canvas
	then rasterize it to a bitmap"
	"sectors := self maps asCollectionOfSectors.
	sectors inspect."
	self map inspect.
	"canvas := TRCanvas new."
	
]

{ #category : #process }
PSMapping >> start [
	<master>
	"do nothing cause it already running"
	Transcript show: 'Running mappinng module'; cr.
	running := true.
	"[ self process ] forkAt: Processor userBackgroundPriority "
]

{ #category : #process }
PSMapping >> stop [
	<master>
	running := false
	"self close.
	self iostream: nil"
]
