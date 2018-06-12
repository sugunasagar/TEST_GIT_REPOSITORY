<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE qml SYSTEM "/wt/query/qml/qml.dtd">
<qml bypassAccessControl="true">
    <parameter name="NUMBER" type="java.lang.String"/>
    <statement>
        <query>
            <select distinct="true">
                <column alias="Deviation" heading="NUMBER"
                    propertyName="number" type="java.lang.String">master&gt;number</column>
                <column alias="Deviation" heading="NAME"
                    propertyName="name" type="java.lang.String">master&gt;name</column>
                <column alias="Deviation" heading="DESCRIPTION"
                    propertyName="description" type="java.lang.String">description</column>
                <column alias="Deviation" heading="REVISION" type="java.lang.String">versionInfo.identifier.versionId</column>
                <column alias="Deviation" heading="STATE"
                    propertyName="state.state" type="wt.lifecycle.State">state.state</column>
                <column alias="Deviation" heading="Vendor" type="java.lang.String">WCTYPE|wt.change2.WTVariance|com.ptc.Deviation~IBA|VENDOR</column>
                <column alias="Deviation" heading="VendorAlternative" type="java.lang.String">WCTYPE|wt.change2.WTVariance|com.ptc.Deviation~IBA|VENDOR_ALTERNATIVE</column>
                <column alias="Deviation" heading="DeviateFrom" type="java.lang.String">WCTYPE|wt.change2.WTVariance|com.ptc.Deviation~IBA|DEVIATE_FROM</column>
                <column alias="Deviation" heading="DeviateTo" type="java.lang.String">WCTYPE|wt.change2.WTVariance|com.ptc.Deviation~IBA|DEVIATE_TO</column>
                <column alias="Deviation" heading="EngineeringAnalysis" type="java.lang.String">WCTYPE|wt.change2.WTVariance|com.ptc.Deviation~IBA|ENGINEERING_ANALYSIS</column>
                <object alias="Workflow Process" heading="InitiatedBy" propertyName="creator.displayName">
                    <property name="creator">
                        <property name="displayName"/>
                    </property>
                </object>
                <column alias="Workflow Process" heading="StartedOn"
                    propertyName="createTimestamp" type="java.sql.Timestamp">thePersistInfo.createStamp</column>
                <column alias="Deviation" heading="ExpireBy" type="java.lang.String">WCTYPE|wt.change2.WTVariance|com.ptc.Deviation~IBA|EXPIRE_BY</column>
                <column alias="Deviation" heading="ExpirationDate" type="java.sql.Timestamp">WCTYPE|wt.change2.WTVariance|com.ptc.Deviation~IBA|EXPIRE_DATE</column>
                <column alias="Deviation" heading="BusinessUnit" type="java.lang.String">WCTYPE|wt.change2.WTVariance|com.ptc.Deviation~IBA|BUSINESS_UNIT</column>
                <column alias="Deviation" heading="PrimaryLocation" type="java.lang.String">WCTYPE|wt.change2.WTVariance|com.ptc.Deviation~IBA|LOCATION_PRIMARY</column>
                <column alias="Deviation" heading="LocationAffected" type="java.lang.String">WCTYPE|wt.change2.WTVariance|com.ptc.Deviation~IBA|LOCATIONAFFECTED</column>
                <object alias="Reported Against"
                    heading="Document Number- Name, Revision" propertyName="roleBObject.identity">
                    <property name="roleBObject">
                        <property name="identity"/>
                    </property>
                </object>
                <column alias="Reported Against"
                    heading="ApprovedQuantity"
                    propertyName="approvedQuantity" type="double">approvedQuantity</column>
            </select>
            <from>
                <table alias="Deviation">WCTYPE|wt.change2.WTVariance|com.ptc.Deviation</table>
                <table alias="Document" outerJoinAlias="Deviation">wt.doc.WTDocument</table>
                <table alias="Reported Against">wt.change2.ReportedAgainst</table>
                <table alias="Work Item">wt.workflow.work.WorkItem</table>
                <table alias="Wf Assignment">wt.workflow.work.WfAssignment</table>
                <table alias="Wf Assigned Activity">wt.workflow.work.WfAssignedActivity</table>
                <table alias="Workflow Process">wt.workflow.engine.WfProcess</table>
            </from>
            <where>
                <compositeCondition type="and">
                    <condition>
                        <operand>
                            <column alias="Deviation" heading="Number"
                                propertyName="number" type="java.lang.String">master&gt;number</column>
                        </operand>
                        <operator type="like"/>
                        <operand>
                            <parameterTarget name="NUMBER"/>
                        </operand>
                    </condition>
                    <condition>
                        <operand>
                            <column alias="Deviation"
                                heading="Latest Version"
                                propertyName="latest" type="boolean">latest</column>
                        </operand>
                        <operator type="equal"/>
                        <operand>
                            <constant heading="1" isMacro="false"
                                type="java.lang.Object" xml:space="preserve">1</constant>
                        </operand>
                    </condition>
                </compositeCondition>
            </where>
            <linkJoin>
                <join name="wt.workflow.work.WorkItemLink">
                    <aliasTarget alias="Wf Assignment"/>
                    <aliasTarget alias="Work Item"/>
                </join>
                <join name="wt.workflow.work.ActivityAssignmentLink">
                    <aliasTarget alias="Wf Assigned Activity"/>
                    <aliasTarget alias="Wf Assignment"/>
                </join>
                <join name="wt.change2.ReportedAgainst">
                    <aliasTarget alias="Deviation"/>
                    <aliasTarget alias="Document"/>
                </join>
            </linkJoin>
            <referenceJoin>
                <join name="primaryBusinessObject">
                    <aliasTarget alias="Work Item"/>
                    <aliasTarget alias="Deviation"/>
                </join>
                <join name="parentProcessRef">
                    <aliasTarget alias="Wf Assigned Activity"/>
                    <aliasTarget alias="Workflow Process"/>
                </join>
                <join name="roleAObjectRef">
                    <aliasTarget alias="Reported Against"/>
                    <aliasTarget alias="Deviation"/>
                </join>
            </referenceJoin>
        </query>
    </statement>
</qml>
