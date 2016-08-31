package hotmem;

#if cpp
private typedef U8ArrayData = haxe.io.BytesData;
#elseif cs
private typedef U8ArrayData = cs.NativeArray<U8>;
#elseif java
private typedef U8ArrayData = java.NativeArray<U8>;
#else
private typedef U8ArrayData = Int;
#end

@:unreflective
abstract U8Array(U8ArrayData) from U8ArrayData to U8ArrayData {

	@:unreflective
	public var length(get, never):Int;

	@:unreflective
	inline public function new(length:Int) {
#if (flash || js)
		this = @:privateAccess HotMemory.alloc(length) ;
#elseif cpp
		this = new haxe.io.BytesData();
		cpp.NativeArray.setSize(this, length);
#elseif java
		this = new java.NativeArray(length);
#elseif cs
		this = new cs.NativeArray(length);
#end
	}

	@:unreflective inline public function dispose() {
#if hotmem_debug
		__checkValid();
#end

#if (js || flash)
		@:privateAccess HotMemory.free(this #if js  #end);
#elseif (cpp||java||cs)
		this = null;
#else
		this = 0;
#end
	}

	@:unreflective
	@:arrayAccess inline function set(index:Int, element:U8) {
#if hotmem_debug
		__checkValid();
		__checkBounds(index);
#end

#if flash
		HotMemory.setU8((index) + this, element);
#elseif js
		HotMemory.setU8elem(index + this, element);
#elseif cpp
		untyped __cpp__("((cpp::UInt8*){0}->GetBase())[{1}] = {2}", this, index, element);
#elseif (java||cs)
		this[index] = element;
#end
	}

	@:unreflective
	@:arrayAccess inline function get(index:Int):U8 {
#if hotmem_debug
		__checkValid();
		__checkBounds(index);
#end

#if flash
		return HotMemory.getU8((index) + this);
#elseif js
		return HotMemory.getU8elem(index + this);
#elseif cpp
		return untyped __cpp__("((cpp::UInt8*){0}->GetBase())[{1}]", this, index);
#elseif (java||cs)
		return this[index];
#else
		return 0;
#end
	}

	@:unreflective
	inline function get_length():Int {
#if hotmem_debug
		__checkValid();
#end

#if flash
		return HotMemory.getI32(this - 4);
#elseif js
		return HotMemory.getI32((this) - 4);
#elseif cpp
		return this.length;
#elseif (java||cs)
		return this.length;
#else
		return 0;
#end
	}

#if (js||flash||cpp)
	@:unreflective
	@:access(hotmem.HotView)
	inline public function view(atElement:Int = 0):HotView {
#if hotmem_debug
		__checkBounds(atElement);
		__checkValid();
#end

		
		return new HotView(this, atElement);
		
	}
#end

#if hotmem_debug
	function __checkBounds(index:Int) {
		if(index < 0 || index >= length) throw 'index out of bounds [index: $index, length: $length]';
	}

	function __checkValid() {
#if (js||cs||java||cpp)
		if(this == null) throw "Array is not created";
#else
		if(this == 0) throw "Array is not created";
#end
	}
#end
}