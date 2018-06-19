package com.irco.deviation;

import java.util.ListResourceBundle;

/**
*	@author Rahul Raut
*	@version 1.0
*/

public class DeviationResource extends ListResourceBundle
{


	//Changes done by Suguna Sagar 1234-Changes// 32323

    static final Object contents[][] = {
       {
            "variance.deviationReport.description", "Deviation Report"
        }, {
            "variance.deviationReport.title", "Deviation Report"
        }, {
            "variance.deviationReport.tooltip", "Deviation Report"
        }, {
            "variance.deviationReport.icon", "DeviationReport.gif"
        }, {
            "test1.demo1.description", "Deviation Report"
        }, {
            "test1.demo1.title", "Deviation Report"
        }, {
            "test1.demo1.tooltip", "Deviation Report"
        }, {
            "test1.demo1.icon", "DeviationReport.gif"
        }

    };
    
    //Second chnage

    public DeviationResource()
    {
    }

    public Object[][] getContents()
    {
        return contents;
    }

}
