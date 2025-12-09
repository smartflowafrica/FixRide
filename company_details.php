<?php
require 'inc/checklogin.php';
require 'inc/Connection.php';
require 'inc/header.php';

if (empty($_GET['id'])) {
    header('Location: company_list.php');
    exit;
}

$company_id = intval($_GET['id']);

// Handle commission update
if ($_SERVER['REQUEST_METHOD'] == 'POST' && isset($_POST['update_commission'])) {
    $new_rate = floatval($_POST['commission_rate']);
    $car->query("UPDATE tbl_company SET commission_rate = $new_rate WHERE id = $company_id");
    echo "<script>alert('Commission rate updated!');</script>";
}

$company = $car->query("SELECT * FROM tbl_company WHERE id = $company_id")->fetch_assoc();
if (!$company) {
    echo "<script>alert('Company not found'); window.location='company_list.php';</script>";
    exit;
}

// Get stats
$car_count = $car->query("SELECT COUNT(*) as cnt FROM tbl_car WHERE company_id = $company_id")->fetch_assoc()['cnt'];
$booking_stats = $car->query("SELECT 
    COUNT(*) as total,
    SUM(book_status = 'Completed') as completed,
    SUM(book_status = 'Pending') as pending,
    SUM(book_status = 'Pick_Up') as active,
    SUM(book_status = 'Cancelled') as cancelled
FROM tbl_book b JOIN tbl_car c ON b.car_id = c.id WHERE c.company_id = $company_id")->fetch_assoc();

$earnings = $car->query("SELECT 
    COALESCE(SUM(total_amount), 0) as total_revenue,
    COALESCE(SUM(commission_amount), 0) as total_commission,
    COALESCE(SUM(company_earning), 0) as company_earnings
FROM tbl_commission WHERE company_id = $company_id AND status = 'paid'")->fetch_assoc();

$wallet = $car->query("SELECT * FROM tbl_company_wallet WHERE company_id = $company_id")->fetch_assoc();

$pending_payout = $car->query("SELECT SUM(amount) as total FROM tbl_company_payout 
    WHERE company_id = $company_id AND status IN ('pending', 'processing')")->fetch_assoc()['total'] ?? 0;

// Get city
$city = $company['city_id'] ? $car->query("SELECT title FROM tbl_city WHERE id = " . $company['city_id'])->fetch_assoc() : null;
?>

<div class="page-wrapper">
    <div class="page-content">
        <div class="page-breadcrumb d-none d-sm-flex align-items-center mb-3">
            <div class="breadcrumb-title pe-3">Company Details</div>
            <div class="ps-3">
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb mb-0 p-0">
                        <li class="breadcrumb-item"><a href="dashboard.php"><i class="bx bx-home-alt"></i></a></li>
                        <li class="breadcrumb-item"><a href="company_list.php">Companies</a></li>
                        <li class="breadcrumb-item active"><?= $company['company_name'] ?></li>
                    </ol>
                </nav>
            </div>
            <div class="ms-auto">
                <a href="company_documents.php?id=<?= $company_id ?>" class="btn btn-info">
                    <i class="bx bx-file"></i> Documents
                </a>
            </div>
        </div>

        <div class="row">
            <!-- Company Profile Card -->
            <div class="col-md-4">
                <div class="card">
                    <div class="card-body text-center">
                        <?php if ($company['logo']): ?>
                        <img src="<?= $company['logo'] ?>" alt="Logo" class="rounded-circle mb-3" width="100" height="100">
                        <?php else: ?>
                        <div class="rounded-circle bg-primary d-inline-flex align-items-center justify-content-center mb-3" style="width:100px;height:100px;">
                            <span class="text-white fs-1"><?= substr($company['company_name'], 0, 1) ?></span>
                        </div>
                        <?php endif; ?>
                        
                        <h4><?= $company['company_name'] ?></h4>
                        <p class="text-muted"><?= $company['slug'] ?></p>
                        
                        <?php
                        $badge = match($company['status']) {
                            'active' => 'success',
                            'pending' => 'warning',
                            'suspended' => 'danger',
                            default => 'secondary'
                        };
                        ?>
                        <span class="badge bg-<?= $badge ?> fs-6"><?= ucfirst($company['status']) ?></span>
                        <?php if ($company['is_verified']): ?>
                        <span class="badge bg-info fs-6"><i class="bx bx-check"></i> Verified</span>
                        <?php endif; ?>
                        
                        <hr>
                        
                        <div class="text-start">
                            <p><i class="bx bx-envelope"></i> <?= $company['email'] ?></p>
                            <p><i class="bx bx-phone"></i> <?= $company['phone'] ?></p>
                            <?php if ($city): ?>
                            <p><i class="bx bx-map"></i> <?= $city['title'] ?></p>
                            <?php endif; ?>
                            <?php if ($company['address']): ?>
                            <p><i class="bx bx-location-plus"></i> <?= $company['address'] ?></p>
                            <?php endif; ?>
                            <p><i class="bx bx-calendar"></i> Joined: <?= date('M d, Y', strtotime($company['created_at'])) ?></p>
                        </div>
                    </div>
                </div>

                <!-- Commission Settings -->
                <div class="card mt-3">
                    <div class="card-header">
                        <h5 class="mb-0">Commission Settings</h5>
                    </div>
                    <div class="card-body">
                        <form method="POST">
                            <div class="mb-3">
                                <label class="form-label">Commission Rate (%)</label>
                                <input type="number" name="commission_rate" class="form-control" 
                                    value="<?= $company['commission_rate'] ?>" step="0.01" min="0" max="100">
                                <small class="text-muted">Platform takes this percentage from each booking</small>
                            </div>
                            <button type="submit" name="update_commission" class="btn btn-primary w-100">
                                Update Commission
                            </button>
                        </form>
                    </div>
                </div>
            </div>

            <!-- Stats & Details -->
            <div class="col-md-8">
                <!-- Stats Cards -->
                <div class="row">
                    <div class="col-md-3">
                        <div class="card bg-gradient-info text-white">
                            <div class="card-body">
                                <h2><?= $car_count ?></h2>
                                <p class="mb-0">Total Cars</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card bg-gradient-success text-white">
                            <div class="card-body">
                                <h2><?= $booking_stats['completed'] ?? 0 ?></h2>
                                <p class="mb-0">Completed</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card bg-gradient-warning text-white">
                            <div class="card-body">
                                <h2><?= $booking_stats['pending'] ?? 0 ?></h2>
                                <p class="mb-0">Pending</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card bg-gradient-danger text-white">
                            <div class="card-body">
                                <h2><?= $booking_stats['cancelled'] ?? 0 ?></h2>
                                <p class="mb-0">Cancelled</p>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Financial Overview -->
                <div class="card mt-3">
                    <div class="card-header">
                        <h5 class="mb-0">Financial Overview</h5>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-4 text-center border-end">
                                <h4 class="text-primary"><?= $set['currency'] ?><?= number_format($earnings['total_revenue'] ?? 0, 2) ?></h4>
                                <p class="text-muted mb-0">Total Revenue</p>
                            </div>
                            <div class="col-md-4 text-center border-end">
                                <h4 class="text-success"><?= $set['currency'] ?><?= number_format($earnings['company_earnings'] ?? 0, 2) ?></h4>
                                <p class="text-muted mb-0">Company Earnings</p>
                            </div>
                            <div class="col-md-4 text-center">
                                <h4 class="text-info"><?= $set['currency'] ?><?= number_format($earnings['total_commission'] ?? 0, 2) ?></h4>
                                <p class="text-muted mb-0">Platform Commission</p>
                            </div>
                        </div>
                        <hr>
                        <div class="row">
                            <div class="col-md-6 text-center border-end">
                                <h4 class="text-success"><?= $set['currency'] ?><?= number_format($wallet['available_balance'] ?? 0, 2) ?></h4>
                                <p class="text-muted mb-0">Available Balance</p>
                            </div>
                            <div class="col-md-6 text-center">
                                <h4 class="text-warning"><?= $set['currency'] ?><?= number_format($pending_payout, 2) ?></h4>
                                <p class="text-muted mb-0">Pending Payout</p>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Recent Bookings -->
                <div class="card mt-3">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <h5 class="mb-0">Recent Bookings</h5>
                        <a href="book_data.php?company_id=<?= $company_id ?>" class="btn btn-sm btn-outline-primary">View All</a>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-sm">
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Car</th>
                                        <th>Customer</th>
                                        <th>Amount</th>
                                        <th>Status</th>
                                        <th>Date</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <?php
                                    $recent = $car->query("SELECT b.*, c.car_title, u.name as customer_name
                                        FROM tbl_book b 
                                        JOIN tbl_car c ON b.car_id = c.id 
                                        JOIN tbl_user u ON b.uid = u.id
                                        WHERE c.company_id = $company_id
                                        ORDER BY b.id DESC LIMIT 5");
                                    while ($booking = $recent->fetch_assoc()):
                                    ?>
                                    <tr>
                                        <td>#<?= $booking['id'] ?></td>
                                        <td><?= $booking['car_title'] ?></td>
                                        <td><?= $booking['customer_name'] ?></td>
                                        <td><?= $set['currency'] ?><?= $booking['o_total'] ?></td>
                                        <td>
                                            <?php
                                            $status_badge = match($booking['book_status']) {
                                                'Completed' => 'success',
                                                'Pending' => 'warning',
                                                'Pick_Up' => 'info',
                                                'Cancelled' => 'danger',
                                                default => 'secondary'
                                            };
                                            ?>
                                            <span class="badge bg-<?= $status_badge ?>"><?= $booking['book_status'] ?></span>
                                        </td>
                                        <td><?= date('M d', strtotime($booking['create_date'])) ?></td>
                                    </tr>
                                    <?php endwhile; ?>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<?php require 'inc/footer.php'; ?>
