//= require jquery
//= require jquery_ujs
//= require private_pub
//= require_tree .
//= require twitter/bootstrap



$.fn.swapClass = function( a, b ) {
  var item = $( this );
  
  if( ( !item.hasClass( a ) && !item.hasClass( b ) ) || ( item.hasClass( a ) && item.hasClass( b ) ) ) return false; 
  
  if( item.hasClass( a ) && !item.hasClass( b ) )
    item.removeClass( a ).addClass( b );
  else if( !item.hasClass( a ) && item.hasClass( b ) )
    item.addClass( a ).removeClass( b );
};