/***********************************************************************************************
    2. ASSEMBLE (SQL Version)
************************************************************************************************/
proc sql;
    create table work.Prom_Data_Aggr as 
        select id
            , intck('month', min(SpendDate), "&CutoffDate."d) as PromTime
            , sum(SpendAmount) as PromSpend
            from work.BORG_Spend
                group by id
                    order by id
    ;

    create table work.Target_Data_Aggr as
        select id
            , count(id) as TargetAmt
            from work.BORG_TARGETEVENTS
                group by id
                    order by id
    ;


    create table work.bigorganics_assmbl as
        select d.id
            , d.DemAffl
            , d.DemAge
            , d.DemCluster
            , c.DemClusterGroup
            , d.DemGender
            , l.DemReg
            , d.DemTVReg
            , case 
                when s.PromSpend > 20000 then 'Platinum'
                when s.PromSpend >  5000 then 'Gold'
                when s.PromSpend >  0.01 then 'Silver'
                else 'Tin'
            end as PromClass length=12 format=$12. label='Loyalty Status'
            , s.PromSpend label='Total Spend'
            , s.PromTime label='Loyalty Card Tenure'
            , case 
                when t.TargetAmt > 0 then 1 
                else 0
            end as TargetBuy label='Organics Purchase Indicator'
            , case 
                when t.TargetAmt = . then 0
                else t.TargetAmt
            end as TargetAmt label='Organics Purchase Count'
            from work.BORG_DEMOGR as d
                left join work.BORG_DEMREG_LOOKUP as l on d.DemTVReg   = l.DemTVReg
                left join work.BORG_CLUSTERGROUP_LOOKUP as c on d.DemCluster = c.DemCluster
                left join work.Prom_Data_Aggr as s on d.id = s.id
                left join work.Target_Data_Aggr as t on d.id = t.id
                    order by id
    ;
quit;
/***********************************************************************************************
    3. ASSEMBLE (Datastep Version mit Formaten)
************************************************************************************************/
* 3a - Create Formats;
data work.BORG_FMT_DEMREG;
    set work.BORG_DEMREG_LOOKUP;
    rename DemTVReg = Start
        DemReg = Label;

    fmtname = 'BORG_REG';
    type = 'C';
run;

proc format cntlin=work.BORG_FMT_DEMREG;
run;

data work.BORG_FMT_CLSGROUP;
    set work.BORG_CLUSTERGROUP_LOOKUP;
    rename DemCluster = Start
        DemClusterGroup = Label;

    fmtname = 'BORG_CLS';
    type = 'C';
run;

proc format cntlin=work.BORG_FMT_CLSGROUP;
run;

* 3c - Aggregate Tables;
proc means data=work.BORG_TARGETEVENTS noPrint nWay;
    class id;
    var TargetAmt;
    output out=work.Target_Data_Aggr(drop=_freq_ _type_) n=;
run;

proc means data=work.BORG_Spend noPrint nWay;
    class id;
    var SpendAmount SpendDate;
    output out=work.Prom_Data_Aggr(drop=_freq_ _type_) 
       sum(SpendAmount) = PromSpend
       min(SpendDate) = MinSpendDate;
run;

* 3d - Merge Tables;
data work.bigorganics_assmbl_dstp;
    length id $18. DemAffl 8. DemAge 8. DemCluster $3. DemClusterGroup $2. DemGender $2. DemReg $15. DemTVReg $18. PromClass $12. PromSpend 8. PromTime 8. TargetBuy 8. TargetAmt 8.;
    label TargetBuy='Organics Purchase Indicator' TargetAmt='Organics Purchase Amount';
    merge WORK.BORG_DEMOGR(in=in_base)
        work.Target_Data_Aggr(in=in_target)
        work.Prom_Data_Aggr(in=in_spend);
    by id;
    if in_base;

        * format DemClusterGroup $2. DemReg $15.;
        * Apply Lookup Tables;
        label DemClusterGroup ='Neighborhood Cluster-7 Level' DemReg='Geographic Region';
        DemClusterGroup = put(DemCluster, $BORG_CLS.);
        DemReg = put(DemTVReg, $BORG_REG.);

        * Spend Data;
        label PromClass='Loyalty Status' PromSpend='Total Spend' PromTime='Loyalty Card Tenure';
        PromTime = intck('month', MinSpendDate, "&CutoffDate."d);
        *format PromClass $12.;
        select;
            when (PromSpend > 20000) PromClass='Platinum';
            when (PromSpend > 5000) PromClass='Gold';
            when (PromSpend > 0.01) PromClass='Silver';
            otherwise PromClass='Tin';
        end;

    * Target Events;
    if in_target then TargetBuy = 1;
    else do; 
        TargetBuy = 0;
        TargetAmt = 0;
    end;
    drop MinSpendDate;
run;

/***********************************************************************************************
    5 ASSEMBLE (Datastep Version mit Format + Hash)
***********************************************************************************************/
* 5c - Aggregate Tables;
proc means data=work.BORG_TARGETEVENTS noPrint nWay;
    class id;
    var TargetAmt;
    output out=work.Target_Data_Aggr(drop=_freq_ _type_) n=;
run;

proc means data=work.BORG_Spend noPrint nWay;
    class id;
    var SpendAmount SpendDate;
    output out=work.Prom_Data_Aggr(drop=_freq_ _type_) 
        sum(SpendAmount) = PromSpend
        min(SpendDate)   = MinSpendDate;
run;

* 5d - Merge Tables;
data work.bigorganics_assmbl_dstp;
    length id $18. DemAffl 8. DemAge 8. DemCluster $3. DemClusterGroup $2. DemGender $2. DemReg $15. DemTVReg $18. PromClass $12. PromSpend 8. PromTime 8. TargetBuy 8. TargetAmt 8.;
    label DemClusterGroup='Neighborhood Cluster-7 Level' DemReg='Geographic Region' PromClass='Loyalty Status' PromSpend='Total Spend' PromTime='Loyalty Card Tenure' TargetBuy='Organics Purchase Indicator' TargetAmt='Organics Purchase Amount';

    if _N_ = 1 then do;
        declare hash HClsgroup(dataset: 'work.BORG_CLUSTERGROUP_LOOKUP');
        HClsgroup.defineKey('DemCluster');
        HClsgroup.defineData('DemClusterGroup');
        HClsgroup.defineDone();

        declare hash HDemReg (dataset: 'work.BORG_DEMREG_LOOKUP');
        HDemReg.defineKey('DemTVReg');
        HDemReg.defineData('DemReg');
        HDemReg.defineDone();
    end;

    merge WORK.BORG_DEMOGR (in=in_base)
        work.Target_Data_Aggr (in=in_target)
        work.Prom_Data_Aggr(in=in_spend);
    by id;
    if in_base;
        * format DemClusterGroup $2. DemReg $15.;
        * Apply Lookup Tables;

        rc = HClsgroup.find();
        rc = HDemReg.find();
        drop rc;

        * Spend Data;
        PromTime = intck('MONTH', MinSpendDate, "&CutoffDate."d);
        * format PromClass $12.;
        select;
            when (PromSpend > 20000) PromClass='Platinum';
            when (PromSpend >  5000) PromClass='Gold';
            when (PromSpend >  0.01) PromClass='Silver';
            otherwise PromClass='Tin';
        end;
    
    * Target Events;
    if in_target then TargetBuy = 1;
    else do; 
        TargetBuy=0;
        TargetAmt=0;
    end;
    drop MinSpendDate;
run;