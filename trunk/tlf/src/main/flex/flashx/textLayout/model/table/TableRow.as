package flashx.textLayout.model.table
{
	import flashx.textLayout.model.attribute.TableRowAttribute;

	/**
	 * TableRow is a representation of a row of TableData (cells) in a Table. 
	 * @author toddanderson
	 */
	public class TableRow extends TableBaseElement
	{
		public var tableData:Vector.<TableData>;
		public var nextRow:TableRow;
		public var previousRow:TableRow;
		
		public var width:Number;
		public var height:Number;
		
		// Flags for row pertaining to <thead />, <tfoot /> and <tbody />
		public var isHeader:Boolean;
		public var isFooter:Boolean;
		public var isBody:Boolean;
		
		/**
		 * Constuctor. 
		 * @param tableData Vector.<TableData> The list of TableData (cells) related to this row.
		 */
		public function TableRow( tableData:Vector.<TableData> )
		{
			super();
			this.tableData = tableData;
		}
		
		/**
		 * @inherit
		 */
		override protected function setDefaultAttributes():void
		{
			attributes = TableRowAttribute.getDefaultAttributes();
		}
	}
}