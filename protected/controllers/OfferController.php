<?php
/**
 * Acoes do modulo "Campaign".
 *
 * =======================================
 * ###################################
 * MagnusBilling
 *
 * @package MagnusBilling
 * @author Adilson Leffa Magnus.
 * @copyright Copyright (C) 2005 - 2021 MagnusSolution. All rights reserved.
 * ###################################
 *
 * This software is released under the terms of the GNU Lesser General Public License v2.1
 * A copy of which is available from http://www.gnu.org/copyleft/lesser.html
 *
 * Please submit bug reports, patches, etc to https://github.com/magnusbilling/mbilling/issues
 * =======================================
 * Magnusbilling.com <info@magnusbilling.com>
 * 28/10/2012
 */

class OfferController extends Controller
{
    public $attributeOrder = 'id';
    public $filterByUser   = false;
    public function init()
    {
        $this->instanceModel = new Offer;
        $this->abstractModel = Offer::model();
        $this->titleReport   = Yii::t('zii', 'Offer');
        parent::init();
    }

}
