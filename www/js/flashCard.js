/**
 * User: ramon
 * Date: 12/15/12 10:17 PM
 */

$(function () {
   function Card(value) {
      var me = this;
      me.value = value;
   }

   Card.prototype.toString = function() {
      return this.value;
   }

   Card.prototype.createEl = function() {
      return $.format('<div class="card">{0}</div>', this.value);
   }

   function PointCard(value) {
      var me = this;
      Card.call(me, value);
   }

   PointCard.prototype = new Card(null);

   function ArithmeticCard() {

   }

   function AnimalCard() {

   }

   function PlantCard() {

   }

   function EnglishVocabularyCard() {

   }

   function ChineseCharacterCard() {

   }

   var cardManager = {
      cardCont: null,

      // TODO: now we only support PointCard
      createCards:function (cardType, values) {
         var me = this;
         me.cards = [];

         if (!cardType) {
            console.error('cardType is not specified!!!');
            return;
         }

         if (values === null || values === undefined) {
            values = cardType.defaultValues;
         } else if ($.type(values) != 'array') {
            values = [values];
         }

         values.forEach(function(value, index){
            me.cards[index] = new cardType(value);
         });
      },

      play:function () {
         var me = this;
         me.paused = false;
         me.finished = false;

         if (!me._createCardElements()) {
            return;
         }

         me._showCardAtIndex(0);
      },

      _createCardElements: function() {
         var me = this;

         if (!me.cardCont) {
            console.error('cardManager.cardCont is not set');
            return false;
         }

         me.cardCont.empty();
         me.$cards = [];

         me.cards.forEach(function(card, index){
            var $card = $(card.createEl());
            $card.hide();
            me.$cards[index] = $card;

            me.cardCont.append($card);
         });

         return true;
      },

      _showCardAtIndex: function(playCardIndex) {
         var me = this;

         if (me.paused) {
            return;
         }

         if (playCardIndex == me.cards.length) {
            me._playOneRound();
            return;
         }

         var settings = flashCard.settings;
         var duration = 0; //settings.displayTime / 5; // ; 'fast', 'slow'
         var toggleMethod = 'fadeToggle'; // 'toggle', 'fadeToggle', 'slideToggle'

         var __showCurrentCard = function(currentCardIndex){
            var currentCard = me.$cards[currentCardIndex];
            currentCard[toggleMethod](duration, function(){
               window.setTimeout(function(){
                  me._showCardAtIndex(currentCardIndex+1);
               }, settings.displayTime);
            });
         }

         var previousCard = playCardIndex == 0 ? me.$cards[me.$cards.length - 1] : me.$cards[playCardIndex - 1];
         if (previousCard && previousCard.is(':visible')) {
            previousCard[toggleMethod](duration, __showCurrentCard(playCardIndex));
         } else {
            __showCurrentCard(playCardIndex);
         }
      },

      _playOneRound: function() {
         var me = this;

         console.log('play one round');

         if (flashCard.settings.repeatPlay) {
            me._showCardAtIndex(0);
         } else {
            console.log('play over');
            me.finished = true;
         }
      },

      pause:function () {
         var me = this;
         me.paused = true;
      },

      reset:function () {

      }
   };

   var flashCard = {
      // TODO: it should be configurable
      settings:{
         displayTime:500, // ms, effect when autoPlay is true
         animation:'fade', // blind, drop, explode, clip, puff
         autoPlay:true,
         randomPlay:true,
         repeatPlay:false
      },

      type:{
         pointCard: PointCard
      },

      cardManager:cardManager
   };

   window.flashCard = flashCard;
});
