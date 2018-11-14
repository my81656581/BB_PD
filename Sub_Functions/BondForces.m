% Calculate bond forces 

function [Nforce,fail]=BondForces(Nforce,Totalbonds,fail,BondType,Stretch,Critical_ts_conc,Critical_ts_steel,c,Volume,fac,DeformedLength,Xdeformed,Ydeformed,Zdeformed,bodyforce,Max_Force,bondlist)


BFmultiplier=zeros(Totalbonds,1);

BforceX=zeros(Totalbonds,1);
BforceY=zeros(Totalbonds,1);
BforceZ=zeros(Totalbonds,1);

fail(fail==1 & BondType==0 & Stretch>Critical_ts_conc)=0;     % Deactivate bond if stretch exceeds critical stretch   Failed = 0 
fail(fail==1 & BondType==1 & Stretch>3*Critical_ts_conc)=0;   % EMU user manual recommends that the critical stretch and bond force are multiplied by a factor of 3 for concrete to steel bonds 
fail(fail==1 & BondType==2 & Stretch>Critical_ts_steel)=0;    % Bond remains active = 1

% Bond force multiplier
BFmultiplier(BondType==1)=3;
BFmultiplier(BondType==0 | BondType==2)=1;

BforceX=BFmultiplier.*fail.*c.*Stretch*Volume.*fac.*(Xdeformed./DeformedLength);
BforceY=BFmultiplier.*fail.*c.*Stretch*Volume.*fac.*(Ydeformed./DeformedLength);
BforceZ=BFmultiplier.*fail.*c.*Stretch*Volume.*fac.*(Zdeformed./DeformedLength);
BforceX(isnan(BforceX))=0;
BforceY(isnan(BforceY))=0;
BforceZ(isnan(BforceZ))=0;

% Nodal force (force on node i) - summing for all bonds attached to node i
for i=1:Totalbonds
    
    nodei=bondlist(i,1);
    nodej=bondlist(i,2);
    
    Nforce(nodei,1)=Nforce(nodei,1)+BforceX(i);
    Nforce(nodej,1)=Nforce(nodej,1)-BforceX(i);
 
    Nforce(nodei,2)=Nforce(nodei,2)+BforceY(i);
    Nforce(nodej,2)=Nforce(nodej,2)-BforceY(i);
    
    Nforce(nodei,3)=Nforce(nodei,3)+BforceZ(i);
    Nforce(nodej,3)=Nforce(nodej,3)-BforceZ(i);
        
end
                                          
% Add body force
Nforce(:,:)=Nforce(:,:)+(bodyforce(:,:)*Max_Force);

end
