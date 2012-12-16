/**
 * User: ramon
 * Date: 12/16/12 12:06 PM
 */

(function($){
   var utils = {
      math: {
         randomInt: function(min, max) {
            var r = this.random(min, max);
            r = Math.round(r);
            if (r < min) {
               r++;
            } else if (r > max) {
               r--;
            }
            return r;
         },

         random: function(min, max) {
            var seed = Math.random();
            return (max - min) * seed + min;
         }
      }
   };

   $.extend(utils);
})(jQuery);