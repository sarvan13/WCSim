#include <algorithm>

void plot_tp(){
// makes 2D plots for theta-phi effective area simulations, with and without reflectors, for a single mPMT configuration
//  gROOT->SetBatch(kTRUE);
  
  //// parameters to set before running code
  TString mpmttype          = "NP2";  // NP1, NP2
  int nevents               = 100000; // depending on value in x_mPMT_tp.mac
  static const int thetamin = -80;     // minimum theta value simulated
  static const int thetamax = 80;     // maximum theta value simulated
  static const int thetaint = 10;     // interval of theta values
  static const int phimin   = -80;     // minimum phi value simulated
  static const int phimax   = 80;     // maximum phi value simulated
  static const int phiint   = 10;     // interval of phi values
  double radius             = 25.;    // radius of source (cm)
  
  static const int ntheta = (thetamax-thetamin)/thetaint + 1;  // number of theta values simulated
  static const int nphi = (phimax-phimin)/phiint + 1;   // number of phi values simulated
  static const int n = ntheta*nphi; // number of .root files for refl/norefl
  double n_pi = 3.14159265359;
  
  cout << "Generating effective area plots for " << mpmttype << "..." << endl;
  
  //// define arrays for theta and phi
  int theta[ntheta];
  TString thetas[ntheta];
  cout << "theta values (degrees):" << endl;
  for (int i=0;i<ntheta;i++){
    theta[i] = thetamin + i*thetaint;
    thetas[i] = Form("%d",theta[i]);
    cout << thetas[i] << ", ";
  }
  cout << endl;
  
  int phi[nphi];
  TString phis[nphi];
  cout << "phi values (degrees):" << endl;
  for (int i=0;i<nphi;i++){
    phi[i] = phimin + i*phiint;
    phis[i] = Form("%d",phi[i]);
    cout << phis[i] << ", ";
  }
  cout << endl;
  
  //// define arrays for effective area
  int nhits_norefl[ntheta][nphi];  // NHits (no reflectors)
  int nhits_refl[ntheta][nphi];    // NHits (with reflectors)
  double ea_norefl[ntheta][nphi];  // effective area (no reflectors)
  double ea_refl[ntheta][nphi];    // effective area (with reflectors)
  double percinc[ntheta][nphi];    // percent increase of reflectors
  
  //// open files, get nhits, and calculate EA (with refl)
  TString filepath = "/neut/data21/gill/sarvanWCSim/WCSim/ReflectorSimulation/cedarFiles/";
  
  int ncount = -1;
  for (int itheta=0;itheta<ntheta;itheta++){ for (int iphi=0;iphi<nphi;iphi++){
    ncount = ncount+1;
    cout << "getting NHits from reflector file " << ncount+1 << " of " << n << "..." << endl;
    
    // define filename
    TString filename = filepath;
    filename += "x_mPMT_refl_" + thetas[itheta] + "_" + phis[iphi] + "_flat.root";
    
    // get NHits from file
    TFile *f = new TFile(filename);
    TTree *t = (TTree*)f->Get("CherenkovHits;1");
    int NHits;
    t->SetBranchAddress("NHits",&NHits);
    
    nhits_refl[itheta][iphi] = 0;
    for (int j=0; j<t->GetEntries(); j++){
      t->GetEntry(j);
      nhits_refl[itheta][iphi] += NHits;
    }
    
    // convert NHits to effective area
    ea_refl[itheta][iphi] = (double)nhits_refl[itheta][iphi]/(double)nevents*n_pi*radius*radius;
    cout << ea_refl[itheta][iphi] << endl;
    delete t;
    f->Close();
    delete f;
  }}
  
/*  //// open files, get nhits, and calculate EA + percent increase (no refl)
  ncount = -1;
  for (int itheta=0;itheta<ntheta;itheta++){ for (int iphi=0;iphi<nphi;iphi++){
    ncount = ncount+1;
    cout << "getting NHits from no-reflector file " << ncount+1 << " of " << n << "..." << endl;
    
    // define filename
    TString filename = filepath;
    filename += "x_mPMT_" + mpmttype + "_norefl_" + thetas[itheta] + "_" + phis[iphi] + "_flat.root";
    
    // get NHits from file
    TFile *f = new TFile(filename);
    TTree *t = (TTree*)f->Get("CherenkovHits;1");
    int NHits;
    t->SetBranchAddress("NHits",&NHits);
    
    nhits_norefl[itheta][iphi] = 0;
    for (int j=0; j<t->GetEntries(); j++){
      t->GetEntry(j);
      nhits_norefl[itheta][iphi] += NHits;
    }
    
    // convert NHits to effective area
    ea_norefl[itheta][iphi] = (double)nhits_norefl[itheta][iphi]/(double)nevents*n_pi*radius*radius;
    
    // calculate percent increase
    percinc[itheta][iphi] = (ea_refl[itheta][iphi]-ea_norefl[itheta][iphi])/ea_norefl[itheta][iphi]*100.;
    
    delete t;
    f->Close();
    delete f;
  }}
*/  
  //// make 2D graphs
  double thetag[n];
  double phig[n];
  double ea_reflg[n];
  double ea_noreflg[n];
  double percincg[n];
  ncount = -1;
  for (int itheta=0;itheta<ntheta;itheta++){ for (int iphi=0;iphi<nphi;iphi++){
    ncount = ncount + 1;
    thetag[ncount]     = theta[itheta];
    phig[ncount]       = phi[iphi];
    ea_reflg[ncount]   = ea_refl[itheta][iphi];
  //  ea_noreflg[ncount] = ea_norefl[itheta][iphi];
  //  percincg[ncount]   = percinc[itheta][iphi];
  }}
  TGraph2D *gea_refl   = new TGraph2D(n,thetag,phig,ea_reflg);
 // TGraph2D *gea_norefl = new TGraph2D(n,thetag,phig,ea_noreflg);
 // TGraph2D *gpercinc   = new TGraph2D(n,thetag,phig,percincg);
  
  //// draw effective area plots
  // with reflector
  TCanvas *c1 = new TCanvas("c1",mpmttype+" Effective Area (refl)",660,600);
  gStyle->SetPalette(1);
  c1->SetRightMargin(0.2);
  gea_refl->SetTitle(mpmttype+" Effective Area (refl)");
  gea_refl->GetXaxis()->SetTitle("#theta (degrees)");
  gea_refl->GetYaxis()->SetTitle("#phi (degrees)");
  gea_refl->GetZaxis()->SetTitle("Effective Area (cm^{2})");
  gea_refl->GetZaxis()->SetTitleOffset(1.2);
  gea_refl->Draw("COLZ");
/*  // without reflector
  TCanvas *c2 = new TCanvas("c2",mpmttype+" Effective Area (norefl)",660,600);
  gStyle->SetPalette(1);
  c2->SetRightMargin(0.2);
  gea_norefl->SetTitle(mpmttype+" Effective Area (no refl)");
  gea_norefl->GetXaxis()->SetTitle("#theta (degrees)");
  gea_norefl->GetYaxis()->SetTitle("#phi (degrees)");
  gea_norefl->GetZaxis()->SetTitle("Effective Area (cm^{2})");
  gea_norefl->GetZaxis()->SetTitleOffset(1.2);
  gea_norefl->SetMaximum(*max_element(ea_reflg,ea_reflg+n));
  gea_norefl->SetMinimum(*min_element(ea_reflg,ea_reflg+n));
  gea_norefl->Draw("COLZ");
  // with/without reflector percent increase
  TCanvas *c3 = new TCanvas("c3",mpmttype+" Effective Area Percent Increase",660,600);
  gStyle->SetPalette(1);
  c3->SetRightMargin(0.2);
  gpercinc->SetTitle(mpmttype+" Effective Area Percent Increase");
  gpercinc->GetXaxis()->SetTitle("#theta (degrees)");
  gpercinc->GetYaxis()->SetTitle("#phi (degrees)");
  gpercinc->GetZaxis()->SetTitle("Effective Area Increase (%)");
  gpercinc->GetZaxis()->SetTitleOffset(1.2);
  gpercinc->Draw("COLZ");
  
  //// write to file
  c1->Print("plots/"+mpmttype+"_tp_plots.pdf(","pdf");
  c2->Print("plots/"+mpmttype+"_tp_plots.pdf","pdf");
  c3->Print("plots/"+mpmttype+"_tp_plots.pdf)","pdf");
*/
}





























