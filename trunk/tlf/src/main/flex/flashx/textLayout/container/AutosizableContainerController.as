package flashx.textLayout.container
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.engine.TextLine;
	
	import flashx.textLayout.elements.Configuration;
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.events.AutosizableContainerControllerEvent;
	import flashx.textLayout.factory.TextFlowTextLineFactory;
	import flashx.textLayout.formats.ITextLayoutFormat;
	import flashx.textLayout.tlf_internal;
	
	use namespace tlf_internal;
	
	[Event(name="resizeComplete", type="flashx.textLayout.events.AutosizableContainerControllerEvent")]
	public class AutosizableContainerController extends ContainerController
	{	
		protected var _uid:String;
		protected var _elements:Vector.<FlowElement>;
		protected var _containerFlow:TextFlow;
		
		protected var _actualHeight:Number = Number.NaN;
		protected var _previousHeight:Number = Number.NaN;
		protected var _background:Shape;
		
		protected static var UID:int;
		
		public function AutosizableContainerController( container:AutosizableControllerContainer, compositionWidth:Number=100, compositionHeight:Number=100 )
		{
			super(container, compositionWidth, compositionHeight);
			
			container.initialize( this );
			
			_uid = "AutosizableContainerController" + AutosizableContainerController.UID++;
			_elements = new Vector.<FlowElement>();
			_containerFlow = new TextFlow();
			
			_background = new Shape();
			_background.graphics.beginFill( 0xFF0000, 0.3 );
			_background.graphics.drawRect( 0, 0, compositionWidth, compositionHeight );
			_background.graphics.endFill();
			container.addChildAt( _background, 0 );
		}
		
		protected function handleLineCreation( line:TextLine ):void
		{
			var bounds:Rectangle = line.getBounds( container );
			var pt:Point = container.localToGlobal( new Point( bounds.left, bounds.top ) );
			_actualHeight = pt.y + bounds.height + line.descent;
			
			_background.graphics.clear();
			_background.graphics.beginFill( 0xFF0000, 0.3 );
			_background.graphics.drawRect( 0, 0, compositionWidth, _actualHeight );
			_background.graphics.endFill();
		}
		
		protected function containsElement( element:FlowElement ):Boolean
		{
			var i:int = _elements.length;
			while( --i > -1 )
			{
				if( _elements[i] == element )
					return true;
			}
			return false;
		}
		
		protected function getElementIndex( element:FlowElement ):Number
		{
			var index:Number;
			var i:int = _elements.length;
			while( --i > -1 )
			{
				if( _elements[i] == element )
				{
					index = i;
					break;
				}
			}
			return index;
		}
		
		protected function removeElementFromList( element:FlowElement ):void
		{
			var index:Number = getElementIndex( element );
			if( !isNaN(index) )
			{
				_elements.splice( index, 1 );	
			}
		}
		
		public function addMonitoredElement( element:FlowElement ):void
		{
			if( !containsElement( element ) )
			{
				element.uid = _uid;
				_elements.push( element );
			}
		}
		public function removeMonitoredElement( element:FlowElement ):void
		{
			if( containsElement( element ) )
			{
				removeElementFromList( element );
				element.uid = null;
			}
		}
		
		public function processContainerHeight():void
		{
			_previousHeight = ( isNaN(_actualHeight) ) ? compositionHeight : _actualHeight;
			
			var format:ITextLayoutFormat = _computedFormat;
			var config:Configuration = new Configuration();
			config.textFlowInitialFormat = format;
			
			while( _containerFlow.numChildren > 0 )
			{
				_containerFlow.removeChildAt( 0 );
			}
			_containerFlow.format = format;
			
			var i:int = 0;
			var elementsCopy:Vector.<FlowElement> = getMonitoredElements();
			for( i = 0; i < elementsCopy.length; i++ )
			{
				_containerFlow.addChild( elementsCopy[i].deepCopy() );
			}
			
			var bounds:Rectangle = new Rectangle( 0, 0, compositionWidth, 1000000 );
			var factory:TextFlowTextLineFactory = new TextFlowTextLineFactory();
			factory.compositionBounds = bounds;
			factory.createTextLines( handleLineCreation, _containerFlow );
			
			setCompositionSize( compositionWidth, _actualHeight );
			
			var offset:Number = _actualHeight - _previousHeight;
			if( offset != 0 )
			{
				container.dispatchEvent( new AutosizableContainerControllerEvent( AutosizableContainerControllerEvent.RESIZE_COMPLETE, this, offset ) );
			}
		}
		
		public function getUID():String
		{
			return _uid;
		}
		
		public function getMonitoredElements():Vector.<FlowElement>
		{
			var i:int;
			var element:FlowElement;
			var elements:Vector.<FlowElement> = new Vector.<FlowElement>();
			for( i = 0; i < textFlow.numChildren; i++ )
			{
				element = textFlow.getChildAt( i ) as FlowElement;
				if( element.uid == _uid )
					elements.push( element );
			}
			return elements.slice();
		}
		
		public function get actualHeight():Number
		{
			return _actualHeight;
		}
	}
}