function blockplot(b,NBLOCKIN)

for i = 1:NBLOCKIN,

plot([b(i).px_x(1) b(i).px_x(2)] , [b(i).px_r(1),b(i).px_r(2)])
plot([b(i).px_x(2) b(i).px_x(3)] , [b(i).px_r(2),b(i).px_r(3)])
plot([b(i).px_x(3) b(i).px_x(4)] , [b(i).px_r(3),b(i).px_r(4)])
plot([b(i).px_x(4) b(i).px_x(1)] , [b(i).px_r(4),b(i).px_r(1)])

plot(b(i).px_x(1),b(i).px_r(1),'o','markersize',8,'markerfacecolor',[0.8 0.8 0.8],'markeredgecolor',[0 0 0])
plot(b(i).px_x(2),b(i).px_r(2),'o','markersize',8,'markerfacecolor',[0.8 0.8 0.8],'markeredgecolor',[0 0 0])
plot(b(i).px_x(3),b(i).px_r(3),'o','markersize',8,'markerfacecolor',[0.8 0.8 0.8],'markeredgecolor',[0 0 0])
plot(b(i).px_x(4),b(i).px_r(4),'o','markersize',8,'markerfacecolor',[0.8 0.8 0.8],'markeredgecolor',[0 0 0])

text(mean(b(i).px_x),mean(b(i).px_r),num2str(i));

end